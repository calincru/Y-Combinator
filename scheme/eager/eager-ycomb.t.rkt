#lang racket

(require "eager-ycomb.rkt"
         rackunit)

; Test the factorial function
(define almost-factorial
  (lambda (f)
    (lambda (n)
      (if (= n 0)
          1
          (* n (f (- n 1)))))))

(define noCombFactorial (noCombY almost-factorial))
(define factorial (Y almost-factorial))

(check-equal? (factorial 0) 1 "[Y] The factorial of 0 is 1")
(check-equal? (factorial 5) 120 "[Y] The afctorial of 5 is 120")
(check-equal? (noCombFactorial 0) 1 "[Y] The factorial of 0 is 1")
(check-equal? (noCombFactorial 5) 120 "[Y] The afctorial of 5 is 120")

; Test the fibonacci function
(define almost-fibonacci
  (lambda (f)
    (lambda (n)
      (cond ((= n 0) 0)
            ((= n 1) 1)
            (else (+ (f (- n 1)) (f (- n 2))))))))

(define noCombFibonacci (noCombY almost-fibonacci))
(define fibonacci (Y almost-fibonacci))

(check-equal? (fibonacci 0) 0 "[Y] 0 fibonacci number")
(check-equal? (fibonacci 1) 1 "[Y] 1 fibonacci number")
(check-equal? (fibonacci 2) 1 "[Y] 2 fibonacci number")
(check-equal? (fibonacci 3) 2 "[Y] 3 fibonacci number")
(check-equal? (fibonacci 4) 3 "[Y] 4 fibonacci number")
(check-equal? (fibonacci 5) 5 "[Y] 5 fibonacci number")
(check-equal? (fibonacci 6) 8 "[Y] 6 fibonacci number")
(check-equal? (fibonacci 17) 1597 "[Y] 17 fibonacci number")
(check-equal? (noCombFibonacci 0) 0 "[Y] 0 fibonacci number")
(check-equal? (noCombFibonacci 1) 1 "[Y] 1 fibonacci number")
(check-equal? (noCombFibonacci 2) 1 "[Y] 2 fibonacci number")
(check-equal? (noCombFibonacci 3) 2 "[Y] 3 fibonacci number")
(check-equal? (noCombFibonacci 4) 3 "[Y] 4 fibonacci number")
(check-equal? (noCombFibonacci 5) 5 "[Y] 5 fibonacci number")
(check-equal? (noCombFibonacci 6) 8 "[Y] 6 fibonacci number")
(check-equal? (noCombFibonacci 17) 1597 "[Y] 17 fibonacci number")


; The gcd function
;
; It needs the Y2 pointfix combinator because the recursive function takes two
; arguments.
(define almost-gcd
  (lambda (f)
    (lambda (x y)
      (if (= y 0)
          x
          (f y (modulo x y))))))

(define gcd (Y2 almost-gcd))

(check-equal? (gcd 10 15) 5)
(check-equal? (gcd 10 11) 1)
(check-equal? (gcd 8 4) 4)
(check-equal? (gcd 39 26) 13)
