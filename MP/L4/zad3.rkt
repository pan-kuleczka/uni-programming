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

(define (bst? t)
    (define (bst-rec t)
        (define result-left (if (leaf? t) '() (bst-rec (node-l t))))
        (define result-right (if (leaf? t) '() (bst-rec (node-r t))))
        (define is-bst 
            (or (leaf? t) (and
                (first result-left) (first result-right)
                (< (node-elem t) (second result-right))
                (> (node-elem t) (third result-left))
            ))
        )
        (define min-tree (if (leaf? t) +inf.0
            (min (second result-left) (node-elem t) (second result-right))
        ))
        (define max-tree (if (leaf? t) -inf.0
            (max (third result-left) (node-elem t) (third result-right))
        ))
        (list is-bst min-tree max-tree)
    )
    (first (bst-rec t))
)

(define (sum-paths t)
    (define (sum-paths-rec t init)
        (if (leaf? t) (leaf)
            (node
                (sum-paths-rec (node-l t) (+ init (node-elem t)))
                (+ init (node-elem t))
                (sum-paths-rec (node-r t) (+ init (node-elem t)))
            )
        )
    )
    (sum-paths-rec t 0)
)

( define t
   ( node
     ( node ( leaf ) 2 ( leaf ))
     5
     ( node ( node ( leaf ) 6 ( leaf ))
           8
           ( node ( leaf ) 9 ( leaf )))))

(check-equal? (bst? t) #t)
(sum-paths t)