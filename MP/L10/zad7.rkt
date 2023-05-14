#lang plait

;; and, or
(define-syntax my-and
  (syntax-rules ()
    [(my-and) #t]
    [(my-and x1 x2 ...) (if (not x1) #f (my-and x2 ...))]
    ))

(define-syntax my-or
  (syntax-rules ()
    [(my-or) #f]
    [(my-or x1 x2 ...) (if x1 #t (my-or x2 ...))]
    ))

(module+ test
  (test (my-and #t #f #t #t) #f)
  (test (my-and #t #t #t) #t))

;; my-let, my-let*
(define-syntax my-let
  (syntax-rules ()
    [(my-let [] e) e]
    [(my-let [(x1 e1) (x2 e2) ...] e)
     ((lambda (x1) (my-let [(x2 e2) ...] e))
      e1
      )]
    ))

(define-syntax my-let*
  (syntax-rules ()
    [(my-let* [] e) e]
    [(my-let* [(x1 e1) (x2 e2) ...] e)
     ((lambda (x1 x2 ...) e)
      e1 e2 ...
      )]
    ))

(define x 1)
(define y 2)
(define z 3)

(module+ test
    (test (my-let [(x 2) (y x) (z y)] (+ (+ x y) z) ) 6)
    (test (my-let* [(x 2) (y x) (z y)] (+ (+ x y) z) ) 5)
)
