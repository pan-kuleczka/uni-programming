#lang racket

(define (split xs)
  (define (split-iter a len-a b len-b xs)
    (if (equal? xs null) (cons a b)
       (if (> len-a len-b)
          [split-iter a len-a (cons (car xs) b) (+ len-b 1) (cdr xs)]
          [split-iter (cons (car xs) a) (+ len-a 1) b len-b (cdr xs)]
          )
       )
    )
  (split-iter null 0 null 0 xs)
  )

(define (merge xs ys)
  (define (merge-iter result xs ys)
    (if (equal? xs null)
       (if (equal? ys null)
          result
          (merge-iter (cons (car ys) result) xs (cdr ys))
          )
       (if (equal? ys null)
          (merge-iter (cons (car xs) result) (cdr xs) ys)
          [if (< (car ys) (car xs))
             (merge-iter (cons (car ys) result) xs (cdr ys))
             (merge-iter (cons (car xs) result) (cdr xs) ys)
             ]
          )
       )
    )
  (reverse (merge-iter null xs ys))
  )

(define (merge-sort xs)
  (if (< (length xs) 2) xs
     (let ([halves (split xs)])
       (merge (merge-sort (car halves)) (merge-sort (cdr halves)))
       )
     )
  )
  