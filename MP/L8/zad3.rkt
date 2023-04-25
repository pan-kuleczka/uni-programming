#lang racket

(module deq racket
  (provide
   deq?
   nonempty-deq?
   (contract-out
    [deq-empty? (-> deq? boolean?)]
    [make-deq (-> deq?)]
    [deq-push-front (-> deq? any/c void?)]
    [deq-push-back (-> deq? any/c void?)]
    [deq-pop-front (-> deq? any/c)]
    [deq-pop-back (-> deq? any/c)]))

  (struct deq-node
    ([left #:mutable]
     [val #:mutable]
     [right #:mutable]))

  (struct deq
    ([front #:mutable]
     [back  #:mutable]))

  (define (deq-empty? q)
    (and (null? (deq-front q))
        (null? (deq-back q))))

  (define (nonempty-deq? q)
    (and (deq? q) (deq-node? (deq-front q))))

  (define (make-deq)
    (deq null null))

  (define (deq-push-front q x)
    (if (deq-empty? q)
       (let [(new-node (deq-node null x null))]
         (set-deq-front! q new-node)
         (set-deq-back! q new-node)
         )
       (let [(new-node (deq-node null x (deq-front q)))]
         (set-deq-node-left! (deq-front q) new-node)
         (set-deq-front! q new-node)
         )
       )
    )

  (define (deq-push-back q x)
    (if (deq-empty? q)
       (let [(new-node (deq-node null x null))]
         (set-deq-front! q new-node)
         (set-deq-back! q new-node)
         )
       (let [(new-node (deq-node (deq-back q) x null))]
         (set-deq-node-right! (deq-back q) new-node)
         (set-deq-back! q new-node)
         )
       )
    )

  (define/contract (deq-pop-front q)
    (-> nonempty-deq? any/c)
    (define front (deq-front q))
    (set-deq-front! q (deq-node-right front))
    (if (null? (deq-node-right front))
       (begin
         (set-deq-back! q null)
         (deq-node-val front))
       (deq-node-val front)))

  (define/contract (deq-pop-back q)
    (-> nonempty-deq? any/c)
    (define back (deq-back q))
    (set-deq-back! q (deq-node-left back))
    (if (null? (deq-node-left back))
       (begin
         (set-deq-front! q null)
         (deq-node-val back))
       (deq-node-val back))))

(require 'deq)
(require rackunit)
(define queue (make-deq))
(deq-push-back queue 2)
(deq-push-back queue 3)
(deq-push-front queue 1)
(deq-push-back queue 4)
(deq-push-back queue 5)
(check-equal? (deq-pop-back queue) 5)
(check-equal? (deq-pop-front queue) 1)
