#lang racket

( let ([x 3]) 
   (+ x y)) ; x związane

( let ([x 1] 
       [ y (+ x 2) ])
   (+ x y)) ; x, y związane

( let ([x 1])
   ( let ([y (+ x 2) ])
      (* x y))) ; x, y związane

( define (f x y)
   (* x y z )) ; x, y związane

( define (f x)
   ( define (g y z)
      (* x y z)) ; x związane, y, z związane w wywołaniu
   ( f x x x)) 
   