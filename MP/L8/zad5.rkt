#lang plait

(define-type Op-Unary
  (op-neg) (op-fact))

(define-type Op-Binary
  (op-add) (op-mul) (op-sub) (op-div) (op-pow))

(define-type Exp
  (exp-number [n : Number])
  (exp-op-unary [op : Op-Unary] [e : Exp])
  (exp-op-binary [op : Op-Binary] [e1 : Exp] [e2 : Exp]))

(define (parse-Op-Unary s)
  (let ([sym (s-exp->symbol s)])
    (cond
      [(equal? sym '-) (op-neg)]
      [(equal? sym '!) (op-fact)])))

(define (parse-Op-Binary s)
  (let ([sym (s-exp->symbol s)])
    (cond
      [(equal? sym '+) (op-add)]
      [(equal? sym '-) (op-sub)]
      [(equal? sym '*) (op-mul)]
      [(equal? sym '/) (op-div)]
      [(equal? sym '**) (op-pow)])))

(define (parse-Exp s)
  (cond
    [(s-exp-number? s) (exp-number (s-exp->number s))]
    [(s-exp-list? s) (let ([xs (s-exp->list s)])
                       (cond
                         [(= (length xs) 2) (exp-op-unary
                                             (parse-Op-Unary (first xs))
                                             (parse-Exp (second xs))
                                             )]
                         [(= (length xs) 3) (exp-op-binary
                                             (parse-Op-Binary (first xs))
                                             (parse-Exp (second xs))
                                             (parse-Exp (third xs))
                                             )]
                         ))]))

; ==============================================

(define (neg x) (- 0 x))
(define (fact x) (if (< x 2) 1 (* x (fact (- x 1)))))
(define (expt x y) (if (< y 1) 1 (* x (expt x (- y 1)))))

(define (eval-Op-Unary op)
  (type-case Op-Unary op
    [(op-neg) neg]
    [(op-fact) fact]))

(define (eval-Op-Binary op)
  (type-case Op-Binary op
    [(op-add) +]
    [(op-sub) -]
    [(op-mul) *]
    [(op-div) /]
    [(op-pow) expt]))

(define (eval e)
  (type-case Exp e
    [(exp-number n) n]
    [(exp-op-unary op e1)
     ((eval-Op-Unary op) (eval e1))]
    [(exp-op-binary op e1 e2)
     ((eval-Op-Binary op) (eval e1) (eval e2))]))

(define s (parse-Exp `(! (** 2 3))))
(eval s)
