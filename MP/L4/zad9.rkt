#lang racket
(require rackunit)

(define-struct ord (val priority) #:transparent)
(define-struct hleaf () )
(define-struct hnode (elem rank l r) #:transparent)

(define (heap-rank heap) (if (hleaf? heap) 0 (hnode-rank heap)))

( define ( hord? p h)
    ( or ( hleaf? h)
        (<= p ( ord-priority ( hnode-elem h)))))
        
( define ( rank h)
    ( if ( hleaf? h)
        0
        ( heap-rank h)))

( define ( heap? h)
    ( or ( hleaf? h)
    ( and ( hnode? h)
        ( heap? ( hnode-l h))
        ( heap? ( hnode-r h))
        (<= ( rank ( hnode-r h))
            ( rank ( hnode-l h)))
        (= ( heap-rank h) (+ 1 ( heap-rank ( hnode-r h))))
        ( hord? ( ord-priority ( hnode-elem h))
            ( hnode-l h))
        ( hord? ( ord-priority ( hnode-elem h))
            ( hnode-r h)))))

(define (fix-rank heap)
    (cond   [(hleaf? heap) heap]
            [(hleaf? (hnode-r heap)) heap]
            [(hleaf? (hnode-l heap)) (hnode 
                (hnode-elem heap)
                (heap-rank heap)
                (hnode-r heap)
                (hnode-l heap)
            )]
            [(< (heap-rank (hnode-l heap)) (heap-rank (hnode-r heap))) (hnode 
                (hnode-elem heap)
                (heap-rank heap)
                (hnode-r heap)
                (hnode-l heap)
            )]
            [else heap]
    )
)

(define (make-node elem heap-a heap-b)
    (cond   [(and (hleaf? heap-a) (hleaf? heap-b)) (hnode elem 1 (hleaf) (hleaf))]
            [(hleaf? heap-a) (make-node elem heap-b heap-a)]
            [else
                (define priority-a (if (hleaf? heap-a) +inf.0 (ord-priority (hnode-elem heap-a))))
                (define priority-b (if (hleaf? heap-b) +inf.0 (ord-priority (hnode-elem heap-b))))
                (cond   [(<= (ord-priority elem) (min priority-a priority-b)) (fix-rank (hnode
                            elem (+ 1 (max (heap-rank heap-a) (heap-rank heap-b))) heap-a heap-b
                        ))]
                        [(>= (ord-priority elem) (priority-a)) (let ([left-heap (make-node
                            elem
                            (hnode-l heap-a)
                            (hnode-r heap-a)
                        )])(fix-rank (hnode
                            (hnode-elem heap-a)
                            (+ 1 (max (heap-rank left-heap) (heap-rank heap-b)))
                            left-heap
                            heap-b
                        )))]
                        [else (let ([right-heap (make-node
                            elem
                            (hnode-l heap-b)
                            (hnode-r heap-b)
                        )])(fix-rank (hnode
                            (hnode-elem heap-b)
                            (+ 1 (max (heap-rank heap-a) (heap-rank right-heap)))
                            heap-a
                            right-heap
                        )))]
                )
]))

(define (heap-singleton elem) (make-node elem (hleaf) (hleaf)))

(define (heap-merge heap-a heap-b)
    (cond   [(hleaf? heap-a) heap-b]
            [(hleaf? heap-b) heap-a]
            [else
                (define priority-a (ord-priority (hnode-elem heap-a)))
                (define priority-b (ord-priority (hnode-elem heap-b)))
                (cond   [(<= priority-a priority-b) (make-node 
                            (hnode-elem heap-a)
                            (heap-merge (hnode-l heap-a) (hnode-r heap-a))
                            heap-b
                        )]
                        [else (make-node 
                            (hnode-elem heap-b)
                            (heap-merge (hnode-l heap-b) (hnode-r heap-b))
                            heap-a
                        )]
                )
]))

(define (heap-pop heap)
    (if (hleaf? heap) heap (heap-merge (hnode-l heap) (hnode-r heap)))
)

(define-struct pq (heap) #:transparent)
(define empty-pq (pq (hleaf)))
(define (pq-insert xpq elem)
    (pq (heap-merge (heap-singleton elem) (pq-heap xpq)))
)
(define (pq-pop xpq)
    (pq (heap-pop (pq-heap xpq)))
)
(define (pq-min xpq)
    (hnode-elem (pq-heap xpq))
)
(define (pq-empty? xpq)
    (hleaf? (pq-heap xpq))
)

(define (pqsort xs)
    (define (make-pq xpq xs)
        (if (null? xs) xpq
            (make-pq (pq-insert xpq (ord (car xs) (car xs))) (cdr xs))
        )
    )
    (define (make-list xpq xs)
        (if (pq-empty? xpq) xs
            (make-list (pq-pop xpq) (append xs (list (ord-val (pq-min xpq)))))
        )
    )
    (make-list (make-pq empty-pq xs) '())
)

(check-equal? (pqsort '(7 3 2 4 1 1)) '(1 1 2 3 4 7))