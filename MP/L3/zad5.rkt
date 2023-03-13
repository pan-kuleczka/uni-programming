#lang racket
(require rackunit)

(define (negatives n)
    (build-list n (lambda (i) (- (- i) 1)))
)

(define (reciprocals n)
    (build-list n (lambda (i) (/ 1 (+ i 1))))
)

(define (evens n)
    (build-list n (lambda (i) (* 2 i)))
)

(define (identityM n)
    (build-list n (lambda (i) (build-list n (lambda (j)
            (if (= i j) 1 0)
        )) 
    ))
)

(check-equal? (negatives 3) '(-1 -2 -3))
(check-equal? (reciprocals 3) '(1 1/2 1/3))
(check-equal? (evens 3) '(0 2 4))
(check-equal? (identityM 3) '((1 0 0) (0 1 0) (0 0 1)))
