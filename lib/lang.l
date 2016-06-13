(symbols 'lang 'pico)

#
# Basic maths
#

(de even ("VAL")
  (= (% "VAL" 2) 0))

(de odd ("VAL")
  (<> (% "VAL" 2) 0))

#
# List manipulation
#

(de foldl ("FUN" "ACC" "LST")
  (if (not "LST")
    "ACC"
    (foldl "FUN" ("FUN" "ACC" (car "LST")) (cdr "LST"))))

(de foldr ("FUN" "LST" "ACC")
  (if (not "LST")
    "ACC"
    ("FUN" (car "LST") (foldr "FUN" (cdr "LST") "ACC"))))

(de dolist ("FUN" "LST")
  (when "LST"
    ("FUN" (car "LST"))
    (dolist "FUN" (cdr "LST"))))

(de tobytes ("LEN" "DAT")
  (if (=0 "LEN")
    NIL
    (cons (& "DAT" 255) (tobytes (dec "LEN") (>> 8 "DAT")))
    ))

#
# Various utilities

(de identity ("VALUE") "VALUE")

#
# I/O operations
#

(de nwr @
  (let ("WRITE" '((e)
                  (let ((len dat) e
                        blst (tobytes (abs len) dat)
                        ilst (if (> len 0) (reverse blst) blst))
                        (dolist '((e) (wr e)) ilst)
                  )))
    (while (args) ("WRITE" (next)))
    ))
