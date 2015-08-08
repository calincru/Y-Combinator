#lang racket

(require "eager-ycomb.rkt"
         rackunit)

(define almost-factorial
  (lambda (f)
    (lambda (n)
      (if (= n 0)
          1
          (* n (f (- n 1)))))))

(define factorial (Y almost-factorial))

(check-equal? (factorial 0) 1 "[Y] The factorial of 0 is 1")
(check-equal? (factorial 5) 120 "[Y] The afctorial of 5 is 120")
