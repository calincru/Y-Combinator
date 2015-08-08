#lang racket

; The pointfix Y Combinator declaration in regular Scheme.
(define Y
  (lambda (f)
    ((lambda (x) (x x))
     (lambda (x) (f (lambda (y) ((x x) y)))))))

(provide Y)
