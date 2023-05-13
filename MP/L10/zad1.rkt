#lang plait

(module+ test
  (print-only-errors #t))

;; abstract syntax -------------------------------

(define-type Op
  (add)
  (sub)
  (mul)
  (div))

(define-type Exp
  (numE [n : Number])
  (opE [op : Op] [args : (Listof Exp)]))

;; parse ----------------------------------------

(define (parse [s : S-Exp]) : Exp
  (cond
    [(s-exp-match? `NUMBER s)
     (numE (s-exp->number s))]
    [(s-exp-match? `{SYMBOL ANY ...} s)
     (opE (parse-op (s-exp->symbol (first (s-exp->list s))))
         (map parse (rest (s-exp->list s))))]
    [else (error 'parse "invalid input")]))

(define (parse-op [op : Symbol]) : Op
  (cond
    [(eq? op '+) (add)]
    [(eq? op '-) (sub)]
    [(eq? op '*) (mul)]
    [(eq? op '/) (div)]
    [else (error 'parse "unknown operator")]))

(module+ test
  (test (parse `2)
       (numE 2))
  (test (parse `{+ 2 1})
       (opE (add) (list (numE 2) (numE 1))))
  (test (parse `{* 3 4})
       (opE (mul) (list (numE 3) (numE 4))))
  (test (parse `{+ {* 3 4} 8})
       (opE (add)
           (list (opE (mul) (list (numE 3) (numE 4))) (numE 8))))
  (test/exn (parse `{{+ 1 2}})
           "invalid input")
  (test/exn (parse `{^ 1 2})
           "unknown operator"))

;; eval --------------------------------------

(define-type-alias Value Number)

(define (op->proc [op : Op]) : ((Listof Value) -> Value)
  (type-case Op op
    [(add) (lambda (xs) (+ (first xs) (second xs)))]
    [(sub) (lambda (xs) (- (first xs) (second xs)))]
    [(mul) (lambda (xs) (* (first xs) (second xs)))]
    [(div) (lambda (xs) (/ (first xs) (second xs)))]))

(define (eval [e : Exp]) : Value
  (type-case Exp e
    [(numE n) n]
    [(opE o args) ((op->proc o) (map eval args))]))

(define (run [e : S-Exp]) : Value
  (eval (parse e)))

(module+ test
  (test (run `2)
       2)
  (test (run `{+ 2 1})
       3)
  (test (run `{* 2 1})
       2)
  (test (run `{+ {* 2 3} {+ 5 8}})
       19))

;; printer ———————————————————————————————————-

(define (print-value [v : Value]) : Void
  (display v))

(define (main [e : S-Exp]) : Void
  (print-value (eval (parse e))))
