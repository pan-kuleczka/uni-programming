#lang plait

(define-type (NNF 'v)
  (nnf-lit [polarity : Boolean] [var : 'v])
  (nnf-conj [l : (NNF 'v)] [r : (NNF 'v)])
  (nnf-disj [l : (NNF 'v)] [r : (NNF 'v)])
  )

; Niech P będzie własnością NNF na typie t, że:
; i)    Dla każdego v typu t P( (nnf-lit #t v) ) i P( (nnf-lit #f v) )
; ii)   Jeśli P(l) i P(r) to P( (nnf-conj l r) ) i P( (nnf-disj l r) )
; Wtedy P zachodzi dla każdego NNF