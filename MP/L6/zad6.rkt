#lang plait

(define-type (NNF 'v)
  (nnf-lit [polarity : Boolean] [var : 'v])
  (nnf-conj [l : (NNF 'v)] [r : (NNF 'v)])
  (nnf-disj [l : (NNF 'v)] [r : (NNF 'v)])
  )

(define-type (Formula 'v)
  (var [var : 'v ])
  (neg [f : (Formula 'v)])
  (conj [l : (Formula 'v)] [r : (Formula 'v)])
  (disj [l : (Formula 'v)] [r : (Formula 'v)])
  )

(define (neg-nnf nnf)
  (cond
    [(nnf-lit? nnf) (nnf-lit (not (nnf-lit-polarity nnf)) (nnf-lit-var nnf))]
    [(nnf-conj? nnf) (nnf-disj (neg-nnf (nnf-conj-l nnf)) (neg-nnf (nnf-conj-r nnf)))]
    [(nnf-disj? nnf) (nnf-conj (neg-nnf (nnf-disj-l nnf)) (neg-nnf (nnf-disj-r nnf)))]
    )
  )

(define (to-nnf f)
  (cond
    [(var? f) (nnf-lit #t (var-var f))]
    [(neg? f) (neg-nnf (to-nnf (neg-f f)))]
    [(conj? f) (nnf-conj (to-nnf (conj-l f)) (to-nnf (conj-r f)))]
    [(disj? f) (nnf-disj (to-nnf (disj-l f)) (to-nnf (disj-r f)))]
    )
  )
