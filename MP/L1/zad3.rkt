#lang racket
(* (+ 2 2) 5)
;(* (+ 2 2) (5)) 5 nie da się obliczyć
; (*(+(2 2) 5) ) 2 i 2 nie mają procedury
; (5 * 4) zła kolejność
; (5 * (2 + 2) ) zła kolejność 
; ((+ 2 3) ) 5 nie da się obliczyć
+
( define + (* 2 3) )
+
(* 2 +)
( define ( five ) 5)
( define four 4)
( five )
four
five
;(four) four to nie procedura 