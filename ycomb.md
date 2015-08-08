# What is the Y-Combinator?
Let's start with writing a simple recursive factorial function:
```scheme
(define (factorial n)
    (if (= n 0)
        1
        (* n (factorial (- n 1)))))
```

This can be written in a more explicit style:
```scheme
(define factorial
    (lambda (n)
        (if (= n 0)
            1
            (* n (factorial (- n 1))))))
```

Notice that inside the definition of the factorial function, we call the same
function to achieve recursion.  We will call this kind of definition an
**explicitly recursive definition**.  You will see soon what we call an
**implicit recursive definition** (spoiler: recursive function which is
*generated* through non-recursive means).

## Goal - Eliminating explicit recursion
Can we still implement the factorial function if we are restricted to not make
any recursive call?  The answer is yes and this will lead us directly to the
Y-Combinator.

## What is the Y-Combinator and what does it do?
The Y-Combinator is a higher-order function which takes a single argument - 
a non-recursive function and returns a version of that function which is
recursive.

More generally, Y-Combinator gives us a way to get recursion in a programming
language that supports first-class functions but that doesn't have recursion
built into it.

Even though we ofter refer to Y as *the* Y-Combinator, in fact there are an
infinite number of Y-Combinators.  We will only be concerned with two of
these, one lazy and one strict.

**Note**: Scheme is a dynamically and strongly typed.

## What a "combinator" is?
A combinator is just a lambda expression with no free variables.  Examples:
```scheme
(lambda (x) x)
(lambda (x) (lambda (y) x))
(x (lambda (y) y))  ; <-- not a combinator, it's a function application
```

So, is our previous definition of factorial a combinator?  Let's look at it
again:
```scheme
(define factorial
    (lambda (n)
        (if (= n 0)
            1
            (* n (factorial (- n 1))))))
```
The answer is **no**, because the *factorial* name in its definition (the
recursive call) is a free variable - it doesn't appear as a formal argument of
the lambda expression.


## Back to the puzzle
What we want to do is come up with a version of this that does the same thing
but doesn't have the recursive call.

It would be nice if you could save all of the function except for the offending
recursive call and put something else there.  That might look like this:
```scheme
(define sort-of-factorial
    (lambda (n)
        (if (= n 0)
            1
            (* n (<???> (- n 1))))))
```

It's a tried-and-true principle of functional programming that if you don't know
exactly what you want to put somewhere in a piece of code, just abstract it out
and make it a parameter of a function.
```scheme
(define almost-factorial
    (lambda (f)
        (lambda (n)
            (if (= n 0)
                1
                (* n (f (- n 1))))))
```

Notice that this trick is not something specific to the factorial function.  You
can do the same thing with any recursive function.  Let's take, for example, the
fibonacci function:
```scheme
(define fibonacci
    (lambda (n)
        (cond ((= n 0) 0)
              ((= n 1) 1)
              (else (+ (fibonacci (- n 1)) (fibonacci (- n 2)))))))

(define almost-fibonacci
    (lambda (f)
        (lambda (n)
            (cond ((= n 0) 0)
                  ((= n 1) 1)
                  (else (+ (fibonacci (- n 1)) (fibonacci (- n 2))))))))
```

So the Y-Combinator will give us recursion wherever we need it as long as we
have the appropriate **almost-** function available.

Now, let's define the identity function:
```scheme
(define identity (lambda (x) x))
```
What happens if we define the factorial (named factorial0 - you will see why)
like this:
```scheme
(define factorial0 (almost-factorial identity))
```
The interesting thing is factorial0 will correctly compute the factorial for all
natural numbers up to and including zero (you'll see soon why we express it this
way).

Now, what if we do this:
```scheme
(define factorial1 (almost-factorial factorial0))
```
which is equivalent to:
```scheme
(define factorial1
    (almost-factorial
        (almost-factorial identity)))
```
Yes, that correctly computes the factorial for all natural numbers up to and
including 1.  You can do this ad infinitum.
```scheme
(define factorial
    (almost-factorial
        (almost-factorial
            (almost-factorial
                (almost-factorial
                    ...))))...)
```
And that would indeed give us the factorial function we need.  One way to look
at this is that **almost-factorial** takes in a crappy factorial function and
outputs a factorial function that is slightly less crappy, in that it will
handle exactly one extra value of the input correctly.

What we have shown is that if we could define an infinite chain of
almost-factorials, that would give us the factorial function.  Another way of
saying this is that the factorial function is the **fixpoint** of
almost-factorial.

## Fixpoints of functions
The fixpoint of a function **f** is a point from the domain on which f is
defined with the property **f(x) = x**.  That is, you give the function a value
and take back the same thing.

Fixpoints don't have to be real numbers.  They can be any type of **first-class
citizen** as long as the function that generates them can take the same thing as
input as it produces as output.

If you have a higher-order function like **almost-factorial** that takes as its
input a function
```scheme
(define almost-factorial
    (lambda (f) ; <-- This lambda here
        (lambda (n)
            (if (= n 0)
                1
                (* n (f (- n 1))))))
```
and produces as output another function with the same *type*
```scheme
(define almost-factorial
    (lambda (f)
        (lambda (n)                  ; \
            (if (= n 0)              ;  \ This
                1                    ;  / lambda
                (* n (f (- n 1)))))) ; /
```
then it is possible to produce its fixpoint, which will naturally be a function
with the same type.

```scheme
fixpoint-function = (almost-factorial fixpoint-function) ; <-- Think x = f(x)
```

By repeatedly substituting the right-hand side of this equation into the
*fixpoint-function* on the right, we get:

```scheme
fixpoint-function =
    (almost-factorial
          (almost-factorial fixpoint-function))

        = (almost-factorial
                (almost-factorial
                          (almost-factorial fixpoint-function)))

        = ...

        = (almost-factorial
                (almost-factorial
                          (almost-factorial
                                      (almost-factorial
                                                    (almost-factorial
                                                    ...)))))
```

As we saw above, this will be the factorial function we want.  Thus, the
fixpoint of almost-factorial will be the factorial function.

That's well and good, but just knowing that factorial is the fixpoint of
almost-factorial doesn't tell us how to compute it .  Wouldn't it be nice if
there was some magical higher-order function that would take as its input a
function like almost-factorial and would output its fixpoint function?

That function is exactly the **Y-Combinator**.  Let's derive it.

## Eliminating (most) explicit recursion (lazy version)
Let's start by specifying what Y does:

    Y f = fixpoint-of-f

What do we know about the fixpoint of f?  We know that

    f fixpoint-of-f = fixpoint-of-f

by the definition of what a fixpoint of a function is.  Therefore, we have:

    Y f = fixpoint-of-f = f fixpoint-of-of

and we can substitute further and get:

    Y f = f (Y f)

And that's it.  It we want it to be expressed as a Scheme function, we would
have to write it like this:
```scheme
(define Y
    (lambda (f)
        (f (Y f))))
```

There are 2 problems with this approach:
* It will only work in a lazy language
* It is not a combinator - we still have a recursion call

Nevertheless, if you're using lazy Scheme, you acn indeed define factorials like
this:

```scheme
(define Y
    (lambda (f)
        (f (Y f))))

(define almost-factorial
    (lambda (f)
        (lambda (n)
            (if (= n 0)
                1
                (* n (f (- n 1)))))))

(define factorial (Y almost-factorial))
```

## Eliminating (most) explicit recursion (strict version)
For programming languages with eager evaluation, we could use a trick to delay
the evaluation of the recursive part of the Y definition from above.  And the
solution in Scheme is the following definition of the Y-Combinator:
```scheme
(define Y
    (lambda (f)
        (f (lambda (x) ((Y f) x)))))
```
The trick is to realize that **Y f** is going to become a function of one
argument (assume curried functions) and that **(lambda (x) ((Y f) x))** is the
same as **(Y f)**.

## Actually deriving the Y-Combinator
### The lazy (normal order)
At this point we want to define not just Y, but a Y *combinator*.

A way to think about what we want to achieve is that you should be able to
replace the name of a combinator with its definition everywhere it's found and
have everything still working (that's not possible with the recursive version we
have so far).

Getting back to our original recursive definition of the factorial function
```scheme
(define (factorial n)
    (if (= n 0)
        1
        (* n (factorial (- n 1)))))
```
another way (other than the previous almost-factorial approach) of achieving 
recursion without explicitly calling factorial in its definition is to pass
itself as an argument:
```scheme
(define (part-factorial self)
    (lambda n)
        (if (= n 0)
            1
            (* n ((self self) (- n 1)))))
```
Now, the only thing we have to do is define the factorial function:
```scheme
(define factorial (part-factorial part-factorial))
(factorial 5) ; Gives 120
```

Notice that we've already defined a version of the factorial function without
using explicit recursion anywhere!  This is a crucial step.

Let's try to get back something like our almost-factorial function by pulling
out the **(self self)** call using a *let* expression:
```scheme
(define (part-factorial self)
    (let ((f (self self)))
        (lambda (n)
            (if (= n 0)
                1
                (* n (f (- n 1)))))))

(define factorial (part-factorial part-factorial))
(factorial 5) ; Gives 120
```

This works fine in a lazy language.  In a strict language, the **(self self)**
will send us into an infinite loop.  Notice that we didn't have this problem
with the previous version, that's because the call was wrapped inside a lambda
definition, while here, it is inside the let statement which hurries the
evaluation.

Note that in a lazy language, the **(self self)** call in the *let* statement
will never be evaluated unless **f** is actually needed (when *n* is different
than 0).

It turns out that any *le* expression can be converted into an equivalent lambda
expression using this equation:

    (let ((x <expr1>)) <expr2>)
    ==> ((lambda (x) <expr2>) <expr1>)

This leads us to:
```scheme
(define (part-factorial self)
    ((lambda (f)
        (lambda (n)
            (if (= n 0)
                1
                (* n (f (- n 1))))))
    (self self)))
```

If you look closely, you'll see that we have our old friend, the
almost-factorial function embedded inside the part-factorial function.  Let's
pull it outside:
```scheme
(define almost-factorial
    (lambda (f)
        (lambda (n)
            (if (= n 0)
                1
                (* n (f (- n 1)))))))

(define (part-factorial self)
    (almost-factorial
        (self self)))

(define factorial (part-factorial part-factorial))
(factorial 5) ; Gives 120
```

We want to get rid of the *part-factorial* function, so first let's rewrite it:
```scheme
(define part-factorial
    (lambda (self)
        (almost-factorial
            (self self))))
```
Then, we can substitute it directly into *factorial*, using a *let* binding:
```scheme
(define almost-factorial
    (lambda (f)
        (lambda (n)
            (if (= n 0)
                1
                (* n (f (- n 1)))))))

(define factorial
    (let ((part-factorial (lambda (self)
                            (almost-factorial
                                (self self)))))
        (part-factorial part-factorial)))

(factorial 5) ; Gives 120
```

We can rewrite the factorial function more concisely by renaming
*part-factorial* to *x*.
```scheme
(define factorial
    (let ((x (lambda (self)
                (almost-factorial (self self)))))
        (x x)))
```

Now let's use the same **let ==> lambda** equivalence:
```scheme
(define almost-factorial
    (lambda (f)
        (lambda (n)
            (if (= n 0)
                1
                (* n (f (- n 1)))))))

(define factorial
    ((lambda (x) (x x))
     (lambda (self)
        (almost-factorial (self self)))))

(factorial 5) ; Gives 120
```

To get this definition more concise, we can rename *self* to *x* (they won't
conflict as they are in different scopes):
```scheme
(define factorial
    ((lambda (x) (x x))
     (lambda (x)
        (almost-factorial (x x)))))
```

This works fine, but it's too specific to the factorial function.  Let's change
it to a generic **make-recursive** function that makes recursive functions from
non-recursive ones (sounds familiar?):
```scheme
(define almost-factorial
    (lambda (f)
        (lambda (n)
            (if (= n 0)
                1
                (* n (f (- n 1)))))))

(define (make-recursive f)
    ((lambda (x) (x x))
     (lambda (x) (f (x x)))))

(define factorial (make-recursive almost-factorial))
(factorial 5) ; Gives 120
```

The **make-recursive** is in fact our Y-Combinator, also know as **normal-order
Y combinator**.
```scheme
(define almost-factorial
    (lambda (f)
        (lambda (n)
            (if (= n 0)
                1
                (* n (f (- n 1)))))))

; Notice the similiarity between this Scheme definition and the lambda-calculus
; syntax: https://upload.wikimedia.org/math/9/0/a/90a21d15fde5ec13d1379791fa4a6548.png
(define (Y f)
    ((lambda (x) (x x))
     (lambda (x) (f (x x)))))

(define factorial (Y almost-factorial))
```

Let's expand it a little bit more:
```scheme
(define Y
    (lambda (f)
        ((lambda (x) (x x))
         (lambda (x) (f (x x))))))
```
and now let's apply the inner lambda on its argument - the other inner lambda:
```scheme
(define Y
    (lambda (f)
        ((lambda (x) (f (x x)))
         (lambda (x) (f (x x))))))
```

What this means is that, for a given function **f** (which is a non-recursive
function like **almost-factorial**), the corresponding recursive function can be
obtained first by computing **(lambda (x) (f (x x)))** and then applying this
lambda expression to itself.

### The strict (applicative-order) Y-Combinator
As we did before, the only trick here is to wrap the **(x x)** call into another
lambda function.  The definition of the applicative-order Y-Combinator becomes:
```scheme
(define Y
    (lambda (f)
        ((lambda (x) (f (lambda (y) ((x x) y))))
         (lambda (x) (f (lambda (y) ((x x) y)))))))

(define factorial (Y almost-factorial))
```


