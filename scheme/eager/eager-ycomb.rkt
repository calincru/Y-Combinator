#lang racket

; The pointfix Y implementation in regular Scheme.
;
; Note that this is not the Y Combinator as this is not a *combinator*.
(define noCombY
  (lambda (f)
    (f (lambda (x) ((noCombY f) x)))))

; The pointfix Y Combinator implementation in regular (eager) Scheme.
(define Y
  (lambda (f)
    ((lambda (x) (x x))
     (lambda (x) (f (lambda (y) ((x x) y)))))))

; The pointfix Y combinator specialized for 2 arguments functions.
;
; Can we achieve recursion for functions with multiple arguments using the
; previous Y combinator?  It looks like we cannot to me.
(define Y2
  (lambda (f)
    ((lambda (x) (x x))
     (lambda (x) (f (lambda (y z) ((x x) y z)))))))

(provide Y
         Y2
         noCombY)
