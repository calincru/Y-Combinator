#lang lazy

; The pointfix Y declaration in lazy Scheme.
;
; Note that this is not the Y Combinator as this is not a *combinator*.
(define noCombY
  (lambda (f)
    (f (Y f))))

; The pointfix Y Combinator declaration in lazy Scheme.
(define Y
  (lambda (f)
    ((lambda (x) (x x))
     (lambda (x) (f (x x))))))

(provide noCombY
         Y)
