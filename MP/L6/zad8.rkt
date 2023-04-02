#lang plait

(define (sorted? xs)
  (or (empty? xs) (empty? (rest xs))
     (and
      (<= (first xs) (second xs))
      (sorted? (rest xs))
      )
     )
  )

(define (insert x xs)
  (cond
    [(empty? xs) (list x)]
    [(< x (first xs)) (cons x xs)]
    [else (cons (first xs) (insert x (rest xs)))]
    )
  )
