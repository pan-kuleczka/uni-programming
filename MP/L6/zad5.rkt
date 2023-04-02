#lang plait

(define-type (NNF 'v)
  (nnf-lit [polarity : Boolean] [var : 'v])
  (nnf-conj [l : (NNF 'v)] [r : (NNF 'v)])
  (nnf-disj [l : (NNF 'v)] [r : (NNF 'v)])
  )

(define (eval-nnf s nnf)
  (cond
    [(nnf-lit? nnf)
     (if (nnf-lit-polarity nnf)
        (s (nnf-lit-var nnf))
        (not (s (nnf-lit-var nnf)))
        )
     ]
    [(nnf-conj? nnf) (and (eval-nnf s (nnf-conj-l nnf)) (eval-nnf s (nnf-conj-r nnf)))]
    [(nnf-disj? nnf) (or (eval-nnf s (nnf-disj-l nnf)) (eval-nnf s (nnf-disj-r nnf)))]
    )
  )
