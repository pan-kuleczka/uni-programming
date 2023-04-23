#lang racket
(define (mreverse! xs)
    (define (mreverse-rec left right)
        (if (not (null? right))
            (let [(next (mcdr right))]
                (set-mcdr! right left)
                (mreverse-rec right next)
            )
            left
        )
    )
    (mreverse-rec null xs)
)

(define x (mcons 1 (mcons 2 (mcons 3 (mcons 4 null)))))
(set! x (mreverse! x))
x
