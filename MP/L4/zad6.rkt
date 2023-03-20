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
(define (merge t1 t2)
    (cond   [(leaf? t1) t2]
            [(leaf? t2) t1]
            [(< (node-elem t1) (node-elem t2)) (node
                (merge t1 (node-l t2))
                (node-elem t2)
                (node-r t2)
            )]
            [else (node
                (merge t2 (node-l t1))
                (node-elem t1)
                (node-r t1)
            )]
    )
)

(define (delete x t)
    (cond   [(leaf? t) t]
            [(equal? (node-elem t) x) (merge
                (node-l t)
                (node-r t)
            )]
            [(< x (node-elem t)) (node
                (delete x (node-l t))
                (node-elem t)
                (node-r t)
            )]
            [else (node
                (node-l t)
                (node-elem t)
                (delete x (node-r t))
            )]
    )
)

( define t
   ( node
     ( node ( leaf ) 2 ( leaf ))
     5
     ( node ( node ( leaf ) 6 ( leaf ))
           8
           ( node ( leaf ) 9 ( leaf )))))

(delete 5 t)