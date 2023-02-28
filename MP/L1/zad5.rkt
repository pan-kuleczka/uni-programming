#lang racket
( define ( a-plus-abs-b a b)
   (( if ( > b 0) + -) a b))

; Jeśli b jest większe od zera, to zostanie dodane, wpw odjęte