#lang racket

(require rackunit)

(define-struct leaf () #:transparent)
(define-struct node (l elem r) #:transparent)

(define (tree? x)
  (cond [(leaf? x) #t]
        [(node? x) (and (tree? (node-l x))
                        (tree? (node-r x)))]
        [else #f]))

(define (tree-node l elem r)
  (if (and (tree? l) (tree? r) (number? elem))
      (node l elem r)
      (error "nieprawidłowe pola węzła")))

(define (tree-alt? x)
  (or (leaf? x)
      (and (node? x)
           (tree-alt? (node-l x))
           (tree-alt? (node-r x)))))

(define (find-bst x t)
  (cond [(leaf? t) #f]
        [(node? t)
         (cond [(= x (node-elem t)) #t]
               [(< x (node-elem t))
                (find-bst x (node-l t))]
               [else
                (find-bst x (node-r t))])]))

(define (insert-bst x t)
  (cond [(leaf? t) (node (leaf) x (leaf))]
        [(node? t)
         (cond [(= x (node-elem t)) t]
                [(< x (node-elem t))
                 (node (insert-bst x (node-l t))
                       (node-elem t)
                       (node-r t))]
                [else
                 (node (node-l t)
                       (node-elem t)
                       (insert-bst x (node-r t)))])]))

(define (fold-tree t init f)
    (if (leaf? t) init
        (f (fold-tree (node-l t) init f) (node-elem t) (fold-tree (node-r t) init f))
    )
)
(define (tree-sum t) (fold-tree t 0 +))
(define (tree-flip t) (fold-tree t (leaf) (lambda (l elem r) (node r elem l))))
(define (tree-height t) (fold-tree t 0 (lambda (l elem r) (+ 1 (max l r)))))
(define (tree-span t) (fold-tree t '(+inf.0 . -inf.0) (lambda (l elem r)
    (cons (min elem (car l) (car r)) (max elem (cdr l) (cdr r)))
)))
(define (flatten t) (fold-tree t '() (lambda (l elem r) 
    (append l '(elem) r)
)))

( define t
   ( node
     ( node ( leaf ) 2 ( leaf ))
     5
     ( node ( node ( leaf ) 6 ( leaf ))
           8
           ( node ( leaf ) 9 ( leaf )))))

(check-equal? (tree-sum t) 30)
(check-equal? (tree-height t) 3)
(check-equal? (tree-span t) '(2.0 . 9.0))
