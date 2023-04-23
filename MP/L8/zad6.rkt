#lang plait

(define-type Exp
  (exp-variable [v : Symbol])
  (exp-number [n : Number])
  (exp-boolean [b : Boolean])
  (exp-lambda [args : (Listof Symbol)] [body : Exp])
  (exp-apply [f : Exp] [args : (Listof Exp)])
  (exp-let [vals : (Listof (Exp * Exp))] [e : Exp])
  (exp-if [condition : Exp] [vtrue : Exp] [vfalse : Exp])
  (exp-cond [vals : (Listof (Exp * Exp))]))