#lang racket
(define (cycle! xs)
    (define (cycle-rec front xs)
        (if (null? (mcdr xs))
            (set-mcdr! xs front)
            (cycle-rec front (mcdr xs))
        )
    )
    (cycle-rec xs xs)
)

(define x (mcons 1 (mcons 2 (mcons 3 (mcons 4 null)))))
(cycle! x)
x
