#lang racket
(require data/heap)
(provide sim? wire?
        (contract-out
         [make-sim        (-> sim?)]
         [sim-wait!       (-> sim? positive? void?)]
         [sim-time        (-> sim? real?)]
         [sim-add-action! (-> sim? positive? (-> any/c) void?)]

         [make-wire       (-> sim? wire?)]
         [wire-on-change! (-> wire? (-> any/c) void?)]
         [wire-value      (-> wire? boolean?)]
         [wire-set!       (-> wire? boolean? void?)]

         [bus-value (-> (listof wire?) natural?)]
         [bus-set!  (-> (listof wire?) natural? void?)]

         [gate-not  (-> wire? wire? void?)]
         [gate-and  (-> wire? wire? wire? void?)]
         [gate-nand (-> wire? wire? wire? void?)]
         [gate-or   (-> wire? wire? wire? void?)]
         [gate-nor  (-> wire? wire? wire? void?)]
         [gate-xor  (-> wire? wire? wire? void?)]

         [wire-not  (-> wire? wire?)]
         [wire-and  (-> wire? wire? wire?)]
         [wire-nand (-> wire? wire? wire?)]
         [wire-or   (-> wire? wire? wire?)]
         [wire-nor  (-> wire? wire? wire?)]
         [wire-xor  (-> wire? wire? wire?)]

         [flip-flop (-> wire? wire? wire? void?)]))


(struct event (exec-time on-execute) #:transparent)
(struct sim ([time #:mutable] [event-heap #:mutable]) #:transparent)
(struct wire ([value #:mutable] [on-change #:mutable] sim) #:transparent)

(define (heap-comparator ea eb)
  (<= (event-exec-time ea) (event-exec-time eb)))
(define (make-sim) (sim 0 (make-heap heap-comparator)))

(define (sim-wait-until! sim time)
  (cond
    [(= 0 (heap-count (sim-event-heap sim)))
     (set-sim-time! sim time)]
    [(< time (event-exec-time (heap-min (sim-event-heap sim))))
     (set-sim-time! sim time)]
    [else (let [(event (heap-min (sim-event-heap sim)))]
            (begin
              (set-sim-time! sim (event-exec-time event))
              (heap-remove-min! (sim-event-heap sim))
              ((event-on-execute event))
              (sim-wait-until! sim time)
            ))]
    ))

(define (sim-wait! sim delta) (sim-wait-until! sim (+ (sim-time sim) delta)))

(define (sim-add-action! sim delta on-execute)
  (heap-add! (sim-event-heap sim) (event (+ (sim-time sim) delta) on-execute)))

(define (make-wire sim)
  (wire #f (list) sim))
(define (wire-on-change! wire func)
  (set-wire-on-change! wire (cons func (wire-on-change wire)))
  (func))

(define (exec-wire-events wire)
  (define (exec-list xs)
    (if (empty? xs) (void) (begin
                             ((car xs))
                             (exec-list (cdr xs))
                             ))
    )
  (exec-list (wire-on-change wire))
  )

(define (wire-set! wire new-value)
  (cond
    [(eq? new-value (wire-value wire)) (void)]
    [else (begin
            (set-wire-value! wire new-value)
            (exec-wire-events wire)
            )]
    ))

(define (gate-not out in)
  (wire-on-change! in (lambda ()
                        (sim-add-action!
                         (wire-sim in)
                         1
                         (lambda ()
                           (wire-set! out (not (wire-value in))))))))

(define (gate-and out in1 in2)
  (wire-on-change! in1 (lambda ()
                         (sim-add-action!
                          (wire-sim in1)
                          1
                          (lambda ()
                            (wire-set! out (and (wire-value in1) (wire-value in2)))))))
  (wire-on-change! in2 (lambda ()
                         (sim-add-action!
                          (wire-sim in2)
                          1
                          (lambda ()
                            (wire-set! out (and (wire-value in1) (wire-value in2))))))))
(define (gate-nand out in1 in2)
  (wire-on-change! in1 (lambda ()
                         (sim-add-action!
                          (wire-sim in1)
                          1
                          (lambda ()
                            (wire-set! out (not (and (wire-value in1) (wire-value in2))))))))
  (wire-on-change! in2 (lambda ()
                         (sim-add-action!
                          (wire-sim in2)
                          1
                          (lambda ()
                            (wire-set! out (not (and (wire-value in1) (wire-value in2)))))))))

(define (gate-or out in1 in2)
  (wire-on-change! in1 (lambda ()
                         (sim-add-action!
                          (wire-sim in1)
                          1
                          (lambda ()
                            (wire-set! out (or (wire-value in1) (wire-value in2)))))))
  (wire-on-change! in2 (lambda ()
                         (sim-add-action!
                          (wire-sim in2)
                          1
                          (lambda ()
                            (wire-set! out (or (wire-value in1) (wire-value in2))))))))

(define (gate-nor out in1 in2)
  (wire-on-change! in1 (lambda ()
                         (sim-add-action!
                          (wire-sim in1)
                          1
                          (lambda ()
                            (wire-set! out (not (or (wire-value in1) (wire-value in2))))))))
  (wire-on-change! in2 (lambda ()
                         (sim-add-action!
                          (wire-sim in2)
                          1
                          (lambda ()
                            (wire-set! out (not (or (wire-value in1) (wire-value in2)))))))))

(define (gate-xor out in1 in2)
  (wire-on-change! in1 (lambda ()
                         (sim-add-action!
                          (wire-sim in1)
                          2
                          (lambda ()
                            (wire-set! out (xor (wire-value in1) (wire-value in2)))))))
  (wire-on-change! in2 (lambda ()
                         (sim-add-action!
                          (wire-sim in2)
                          2
                          (lambda ()
                            (wire-set! out (xor (wire-value in1) (wire-value in2))))))))



(define (wire-not in)
  (define out (make-wire (wire-sim in)))
  (gate-not out in)
  out
  )

(define (wire-and in1 in2)
  (define out (make-wire (wire-sim in1)))
  (gate-and out in1 in2)
  out
  )

(define (wire-nand in1 in2)
  (define out (make-wire (wire-sim in1)))
  (gate-nand out in1 in2)
  out
  )

(define (wire-or in1 in2)
  (define out (make-wire (wire-sim in1)))
  (gate-or out in1 in2)
  out
  )

(define (wire-nor in1 in2)
  (define out (make-wire (wire-sim in1)))
  (gate-nor out in1 in2)
  out
  )

(define (wire-xor in1 in2)
  (define out (make-wire (wire-sim in1)))
  (gate-xor out in1 in2)
  out
  )

(define (bus-set! wires value)
  (match wires
    ['() (void)]
    [(cons w wires)
     (begin
       (wire-set! w (= (modulo value 2) 1))
       (bus-set! wires (quotient value 2)))]))

(define (bus-value ws)
  (foldr (lambda (w value) (+ (if (wire-value w) 1 0) (* 2 value)))
        0
        ws))

(define (flip-flop out clk data)
  (define sim (wire-sim data))
  (define w1  (make-wire sim))
  (define w2  (make-wire sim))
  (define w3  (wire-nand (wire-and w1 clk) w2))
  (gate-nand w1 clk (wire-nand w2 w1))
  (gate-nand w2 w3 data)
  (gate-nand out w1 (wire-nand out w3)))
