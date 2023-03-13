#lang racket
(require rackunit)

(define (list->llist xs)
  (lambda (ys) (append xs ys))
  )

(define (llist->list xs)
  (xs null)
  )

(define llist-null (list->llist null))

(define (llist-singleton x)
  (list->llist (list x))
  )

(define (llist-append f g)
  (lambda (xs) (f (g xs)))
  )

(check-equal? '(1 2 3 4) (llist->list (llist-append (list->llist '(1 2)) (list->llist '(3 4)))))

(define (foldr-llist-reverse xs)
  (llist->list
   (foldr (lambda (y x) (llist-append x (llist-singleton y))) llist-null xs)
   )
  )

(check-equal? (foldr-llist-reverse '(1 2 3 4)) '(4 3 2 1))

; Wydajność tej procedury jest znacznie większa - liniowa, ponieważ sklejanie list kosztuje tylko
; czas stały
