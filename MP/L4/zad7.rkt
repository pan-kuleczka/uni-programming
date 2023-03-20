#lang racket

(require rackunit)

(define-struct queue (left-list right-list) #:transparent)

(define empty-queue (queue '() '()))
(define (empty? q) (null? (queue-left-list q)))
(define (push-back q x) (cond   [(null? (queue-left-list q)) (queue (list x) '())]
                                [else (queue (queue-left-list q) (cons x (queue-right-list q)))]
))
(define (front q) (if (empty? q) null (car (queue-left-list q))))
(define (pop q) (cond   [(empty? q) q]
                        [(null? (cdr (queue-left-list q))) (queue
                            (reverse (queue-right-list q))
                            '()
                        )]
                        [else (queue
                            (cdr (queue-left-list q))
                            (queue-right-list q)
                        )]
))

(check-equal? (front (pop (pop (push-back (push-back (push-back empty-queue 4) 3) 2)))) 2)