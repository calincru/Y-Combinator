#lang lazy

; The pointfix Y implementation in lazy Scheme.
;
; Note that this is not the Y Combinator as this is not a *combinator*.
(define noCombY
  (lambda (f)
    (f (noCombY f))))

; The pointfix Y Combinator implementation in lazy Scheme.
(define Y
  (lambda (f)
    ((lambda (x) (x x))
     (lambda (x) (f (x x))))))

(provide noCombY
         Y)
