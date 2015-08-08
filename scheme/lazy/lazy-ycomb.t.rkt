#lang lazy

; No rackunit in the lazy package?
(require "lazy-ycomb.rkt")


; Helper functions to run both implementations (noCombY and Y)
(define equalBoth1
  (lambda (fun1 fun2 arg expected)
    (and (equal? (fun1 arg) expected)
         (equal? (fun2 arg) expected))))

(define equalBoth2
  (lambda (fun1 fun2 arg1 arg2 expected)
    (and (equal? (fun1 arg1 arg2) expected)
         (equal? (fun2 arg1 arg2) expected))))

(define expect-true
  (lambda (condition)
    (if condition
      (display "Passed\n")
      (display "Failed\n"))))



; The factorial function
(define almost-factorial
  (lambda (f)
    (lambda (n)
      (if (= n 0)
          1
          (* n (f (- n 1)))))))

(define noCombFactorial (noCombY almost-factorial))
(define factorial (Y almost-factorial))

(expect-true (equalBoth1 noCombFactorial factorial 0 1))
(expect-true (equalBoth1 noCombFactorial factorial 5 120))

; The fibonacci function
(define almost-fibonacci
  (lambda (f)
    (lambda (n)
      (cond ((= n 0) 0)
            ((= n 1) 1)
            (else (+ (f (- n 1)) (f (- n 2))))))))

(define noCombFibonacci (noCombY almost-fibonacci))
(define fibonacci (Y almost-fibonacci))

(expect-true (equalBoth1 noCombFibonacci fibonacci 0 0))
(expect-true (equalBoth1 noCombFibonacci fibonacci 1 1))
(expect-true (equalBoth1 noCombFibonacci fibonacci 2 1))
(expect-true (equalBoth1 noCombFibonacci fibonacci 3 2))
(expect-true (equalBoth1 noCombFibonacci fibonacci 4 3))
(expect-true (equalBoth1 noCombFibonacci fibonacci 5 5))
(expect-true (equalBoth1 noCombFibonacci fibonacci 6 8))
(expect-true (equalBoth1 noCombFibonacci fibonacci 17 1597))

; The gcd function
(define almost-gcd
  (lambda (f)
    (lambda (x y)
      (if (= y 0)
          x
          (f y (modulo x y))))))

(define noCombGcd (noCombY almost-gcd))
(define gcd (Y almost-gcd))

(expect-true (equalBoth2 noCombGcd gcd 10 15 5))
(expect-true (equalBoth2 noCombGcd gcd 10 11 1))
(expect-true (equalBoth2 noCombGcd gcd 8 4 4))
(expect-true (equalBoth2 noCombGcd gcd 39 26 13))
