#lang racket

(define ifCond #f)
(define ifTrue 2)
(define ifFalse 3)

(or (and ifCond ifTrue) ifFalse)