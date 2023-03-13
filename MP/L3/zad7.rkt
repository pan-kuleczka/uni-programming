#lang racket

(define (foldr-reverse xs)
  (foldr (lambda (y ys) (append ys (list y))) null xs)
  )

(length (foldr-reverse (build-list 10000 identity)))

; Dla listy długości n procedura tworzy n ** 2 consów, z których około n ** 2 - n to nieużytki