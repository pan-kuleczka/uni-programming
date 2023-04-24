#lang plait

(define-type Exp
  (exp-variable [v : Symbol])
  (exp-number [n : Number])
  (exp-boolean [b : Boolean])
  (exp-lambda [args : (Listof Symbol)] [body : Exp])
  (exp-apply [f : Exp] [args : (Listof Exp)])
  (exp-let [vals : (Listof (Symbol * Exp))] [e : Exp])
  (exp-if [condition : Exp] [vtrue : Exp] [vfalse : Exp])
  (exp-cond [vals : (Listof (Exp * Exp))]))

(define (parse-Exp s)
  (cond
    [(s-exp-symbol? s) (exp-variable (s-exp->symbol s))]
    [(s-exp-number? s) (exp-number (s-exp->number s))]
    [(s-exp-boolean? s) (exp-boolean (s-exp->boolean s))]
    [(s-exp-list? s)
     (let ([xs (s-exp->list s)])
       (cond
         [(s-exp-match? `(lambda (SYMBOL ...) ANY) s)
          (exp-lambda (map s-exp->symbol (s-exp->list (second xs))) (parse-Exp (third xs)))
          ]
         [(s-exp-match? `(let ((SYMBOL ANY) ...) ANY) s)
          (exp-let (map (lambda (s) (values
                                     (s-exp->symbol (first (s-exp->list s)))
                                     (parse-Exp (second (s-exp->list s)))))
                       (s-exp->list (second xs))) (parse-Exp (third xs)))
          ]
         [(s-exp-match? `(if ANY ANY ANY) s)
          (exp-if (parse-Exp (second xs)) (parse-Exp (third xs)) (parse-Exp (fourth xs)))
          ]
         [(s-exp-match? `(cond (ANY ANY) ...) s)
          (exp-cond (map (lambda (s) (values
                                      (parse-Exp (first (s-exp->list s)))
                                      (parse-Exp (second (s-exp->list s)))))
                        (s-exp->list (second xs))))
          ]
         [(s-exp-match? `(ANY ANY ...) s)
          (exp-apply (parse-Exp (first xs)) (map parse-Exp (rest xs)))
          ]
         ))]))

(parse-Exp `(if (let [(x 3)] x) #t #f))
