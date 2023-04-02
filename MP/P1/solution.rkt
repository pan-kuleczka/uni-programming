#lang racket
(require rackunit)

(provide (struct-out column-info)
        (struct-out table)
        (struct-out and-f)
        (struct-out or-f)
        (struct-out not-f)
        (struct-out eq-f)
        (struct-out eq2-f)
        (struct-out lt-f)
        table-insert
        table-project
        table-sort
        table-select
        table-rename
        table-cross-join
        table-natural-join)

;; List logical operations
(define (sum-lists xs ys)
  (remove-duplicates (append xs ys))
  )

(define (complement-list xs universe)
  (filter (lambda (x) (not (member x xs))) universe)
  )

(define (isect-lists xs ys)
  (define universe (sum-lists xs ys))
  (complement-list (sum-lists
                    (complement-list xs universe)
                    (complement-list ys universe)
                    ) universe)
  )

;; Sublist selection
(define (filter-indexes list indexes)
  (define (filter-indexes-rec list indexes index)
    (cond
      [(null? list) null]
      [(member index indexes) (cons (car list) (filter-indexes-rec (cdr list) indexes (+ index 1)))]
      [else (filter-indexes-rec (cdr list) indexes (+ index 1))]
      )
    )
  (filter-indexes-rec list indexes 0)
  )

(define (delete-indexes list indexes)
  (define (delete-indexes-rec list indexes index)
    (cond
      [(null? list) null]
      [(not (member index indexes)) (cons (car list) (delete-indexes-rec (cdr list) indexes (+ index 1)))]
      [else (delete-indexes-rec (cdr list) indexes (+ index 1))]
      )
    )
  (delete-indexes-rec list indexes 0)
  )

(define-struct column-info (name type) #:transparent)
(define-struct table (schema rows) #:transparent)

;; Helper list functions
(define (column-names tab) (map column-info-name (table-schema tab)))

;; Type functions
(define types (list 'number 'string 'symbol 'boolean))
(define type-predicates (list number? string? symbol? boolean?))

(define (type? x) (member x types))
(define (type-to-predicate type)
  (if (type? type) (list-ref type-predicates (index-of types type)) (error "Invalid type."))
  )
(define (is-type? x type) ((type-to-predicate type) x))

;; Row verification
(define (is-valid-row row columns)
  (cond
    [(and (null? row) (null? columns)) #t]
    [(or (null? row) (null? columns)) #f]
    [(not (is-type? (car row) (column-info-type (car columns)))) #f]
    [else (is-valid-row (cdr row) (cdr columns))]
    )
  )

;; Select value from row
(define (select-value row col tab)
  (define col-index (index-where
                     (table-schema tab)
                     (lambda
                         (col-info) (eq? (column-info-name col-info) col))))
  (list-ref row col-index)
  )


(define (empty-table columns) (table columns '()))

(define (table-insert row tab)
  (if (is-valid-row row (table-schema tab))
     (table (table-schema tab) (cons row (table-rows tab)))
     (error "Row does not match the schema of the table.")
     )
  )

(define (table-project cols tab)
  (define cols-indexes (indexes-where
                        (table-schema tab)
                        (lambda (col-info) (member (column-info-name col-info) cols))))
  (define new-schema (filter-indexes (table-schema tab) cols-indexes))
  (table new-schema (map
                     (lambda (row) (filter-indexes row cols-indexes))
                     (table-rows tab)
                     ))
  )

(define (table-rename col ncol tab)
  (table
   (map (lambda (col-info)
          (if (eq? (column-info-name col-info) col)
             (column-info ncol (column-info-type col-info))
             col-info
             )
          )
       (table-schema tab)
       )
   (table-rows tab)
   )
  )

;; Compare table values
(define (less-than-values value1 value2)
  (cond
    [(and (number? value1) (number? value2))
     (< value1 value2)]
    [(and (string? value1) (string? value2))
     (string<? value1 value2)]
    [(and (symbol? value1) (symbol? value2))
     (string<? (symbol->string value1) (symbol->string value2))]
    [(and (boolean? value1) (boolean? value2))
     (and (not value1) value2)]
    [else #f]
    )
  )

;; Compare rows by cols
(define (less-than-rows row1 row2 cols tab)
  (cond
    [(null? cols) #f]
    [(less-than-values
      (select-value row1 (car cols) tab)
      (select-value row2 (car cols) tab)
      ) #t]
    [(less-than-values
      (select-value row2 (car cols) tab)
      (select-value row1 (car cols) tab)
      ) #f]
    [else (less-than-rows row1 row2 (cdr cols) tab)]
    )
  )

(define (table-sort cols tab)
  (table
   (table-schema tab)
   (sort (table-rows tab) (lambda (row1 row2) (less-than-rows row1 row2 cols tab)))
   )
  )

(define-struct and-f (l r))
(define-struct or-f (l r))
(define-struct not-f (e))
(define-struct eq-f (name val))
(define-struct eq2-f (name name2))
(define-struct lt-f (name val))

(define (table-select form tab)
  (define rows (table-rows tab))
  (cond
    [(and-f? form) (isect-lists
                    (table-select (and-f-l form) tab)
                    (table-select (and-f-r form) tab)
                    )]
    [(or-f? form) (sum-lists
                   (table-select (or-f-l form) tab)
                   (table-select (or-f-r form) tab)
                   )]
    [(not-f? form) (complement-list (table-select (not-f-e form) tab) rows)]
    [(eq-f? form) (filter
                   (lambda (row)
                     (equal? (select-value row (eq-f-name form) tab) (eq-f-val form))
                     )
                   rows
                   )]
    [(eq2-f? form) (filter
                    (lambda (row)
                      (equal?
                       (select-value row (eq2-f-name form) tab)
                       (select-value row (eq2-f-name2 form) tab)
                       )
                      )
                    rows
                    )]
    [(lt-f? form) (filter
                   (lambda (row)
                     (less-than-values (select-value row (lt-f-name form) tab) (lt-f-val form))
                     )
                   rows
                   )]
    [else (error "Not a valid form.")]
    )
  )

(define (table-cross-join tab1 tab2)
  (table
   (append (table-schema tab1) (table-schema tab2))
   (map
    (lambda (row-pair) (append (first row-pair) (second row-pair)))
    (cartesian-product (table-rows tab1) (table-rows tab2))
    )
   )
  )

(define (table-natural-join tab1 tab2)
  (define col-names-isect (isect-lists (column-names tab1) (column-names tab2)))

  (define tab1-sorted (table-sort col-names-isect tab1))
  (define tab2-sorted (table-sort col-names-isect tab2))

  (define duplicate-indexes (indexes-where
                             (column-names tab2)
                             (lambda (col-name) (member col-name col-names-isect))
                             ))

  (define (join-rows row1 row2)
    (append row1 (delete-indexes row2 duplicate-indexes))
    )

  ;; Compare rows by cols in their respective tabs
  (define (less-than-rows-separate row1 row2 cols tab1 tab2)
    (cond
      [(null? cols) #f]
      [(less-than-values
        (select-value row1 (car cols) tab1)
        (select-value row2 (car cols) tab2)
        ) #t]
      [(less-than-values
        (select-value row2 (car cols) tab2)
        (select-value row1 (car cols) tab1)
        ) #f]
      [else (less-than-rows-separate row1 row2 (cdr cols) tab1 tab2)]
      )
    )

  (define (join-row-lists-rec rows1 rows2)
    (if (null? rows1) '()
       (let* (
              [row1 (car rows1)]
              ;; Rows compared by common columns
              [rows-greater-equal (dropf rows2
                                        (lambda (row2)
                                          (less-than-rows-separate
                                           row2 row1 col-names-isect tab2 tab1)
                                          ))]
              [rows-equal (takef rows-greater-equal
                                (lambda (row2)
                                  (not (less-than-rows-separate
                                        row1 row2 col-names-isect tab1 tab2))
                                  ))]
              [joined-rows (map (lambda (row2) (join-rows row1 row2)) rows-equal)]
              )
         (append joined-rows (join-row-lists-rec (cdr rows1) rows-greater-equal))
         )
       )
    )

  (table
   (isect-lists (table-schema tab1) (table-schema tab2))
   (join-row-lists-rec (table-rows tab1-sorted) (table-rows tab2-sorted))
   )
  )

(define cities
  (table
   (list (column-info 'city    'string)
        (column-info 'country 'string)
        (column-info 'area    'number)
        (column-info 'capital 'boolean))
   (list (list "Wrocław" "Poland"  293 #f)
        (list "Warsaw"  "Poland"  517 #t)
        (list "Poznań"  "Poland"  262 #f)
        (list "Berlin"  "Germany" 892 #t)
        (list "Munich"  "Germany" 310 #f)
        (list "Paris"   "France"  105 #t)
        (list "Rennes"  "France"   50 #f))))

(define countries
  (table
   (list (column-info 'country 'string)
        (column-info 'population 'number))
   (list (list "Poland" 38)
        (list "Germany" 83)
        (list "France" 67)
        (list "Spain" 47))))

(table-insert (list "Miasto" "Państwo" 42 #f) cities)
'()
'()
'()
(table-project '(city country) cities)
'()
'()
'()
(table-rename 'city 'name cities)
'()
'()
'()
(table-sort '(country city) cities)
'()
'()
'()
(table-select (and-f (eq-f 'capital #t) (not-f (lt-f 'area 300))) cities)
'()
'()
'()
(table-cross-join cities (table-rename 'country 'country2 countries))
'()
'()
'()
(table-natural-join cities countries)
