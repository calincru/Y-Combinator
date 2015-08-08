#lang lazy

; No rackunit in the lazy package?
(require "lazy-ycomb.rkt")

(define almost-factorial
  (lambda (f)
    (lambda (n)
      (if (= n 0)
          1
          (* n (f (- n 1)))))))

(define noCombFactorial (noCombY almost-factorial))
(define factorial (Y almost-factorial))

(equal? (noCombFactorial 0) 1)
(equal? (noCombFactorial 5) 120)
(equal? (factorial 0) 1)
(equal? (factorial 5) 120)
