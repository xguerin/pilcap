(symbols 'serializable 'pico)

(load "lib/lang.l")
(load "lib/printer.l")

################################################################################
# Schema entry format
################################################################################

#
# ( BYTE_COUNT SYMBOL_NAME WRITER READER )
# 

################################################################################
# Serializable class
################################################################################

(class +Serializable)

(dm parse ("LENGTH" "APP")
  (let (schlen  (lang~foldl '((acc e) (+ acc (abs (car e)))) 0 (schema This))
        rem     (- "LENGTH" schlen)
        parser '((elt)
                 (let ((len dsc NIL rdr) elt)
                   (default rdr lang~identity)
                   (put This dsc (rdr (rd len)))
                   )))
    (lang~dolist parser (schema This))
    rem
    ))

(dm dump ()
  (let (getter '((elt)
                 (let ((len dsc NIL NIL) elt)
                   (lang~nwr (list len (get This dsc)))
                   )))
    (lang~dolist getter (schema This))
    This
    ))

(dm display ()
  (let (writer  '((elt)
                  (let ((len dsc wtr NIL) elt
                        nam               (name dsc))
                    (prinl (get This dsc))
                    (prinl "| " (align -22 nam) " : " (wtr (get This dsc)))
                    )))
    (lang~dolist writer (schema This))
    ))

(dm expand ()
  (let (builder '((e)
                  (let ((len dsc wtr NIL) elt
                        nam               (name dsc)
                        vll               (get This dsc))
                      (link (cons nam (wtr vll)))
                      )))
    (make (lang~dolist builder (schema This)))
    ))

(dm len ()
  (lang~foldl '((acc e) (+ acc (abs (car e)))) 0 (schema This)))

################################################################################
# Schema validation
################################################################################

(de assert-size ("LAYER" "SIZE")
  (let (adder '((acc elm) (+ acc (abs (car elm))))
        sze   (lang~foldl adder 0 (schema "LAYER"))
        iden  (car (str "LAYER")))
    (when (<> "SIZE" sze)
      (quit (pack "Size for " iden " is " sze ", expected to be " "SIZE")))))
