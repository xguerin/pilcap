(symbols 'serializable 'pico)

(load "lib/lang.l")
(load "lib/printer.l")

################################################################################
# Schema entry format
################################################################################

#
# ( SYMBOL_NAME BYTE_COUNT WRITER READER )
# 

################################################################################
# Serializable class
################################################################################

(class +Serializable)

(dm ident ()
  (pack (cdr (chop (name (car (type This)))))))

(dm display ()
  (let (writer  '((elt)
                  (let ((dsc len wtr NIL) elt
                        nam               (name dsc))
                    (default wtr lang~identity)
                    (prinl "| " (align -22 nam) " : " (wtr (get This dsc)))
                    )))
    (lang~dolist writer (schema This))
    ))

(dm dump ()
  (let (getter '((elt)
                 (let ((dsc len NIL NIL) elt)
                   (lang~nwr (list len (get This dsc)))
                   )))
    (lang~dolist getter (schema This))
    This
    ))

(dm expand ()
  (let (builder '((elt)
                  (let ((dsc len wtr NIL) elt
                        nam               (name dsc)
                        vll               (get This dsc))
                      (default wtr lang~identity)
                      (link (cons nam (wtr vll)))
                      )))
    (make (lang~dolist builder (schema This)))
    ))

(dm len ()
  (lang~foldl
    '((acc e) (+ acc (abs (cadr e))))
    0
    (schema This)))

(dm parse ("LENGTH" "APP")
  (let (rem     (- "LENGTH" (len This))
        parser '((elt)
                 (let ((dsc len NIL rdr) elt)
                   (default rdr lang~identity)
                   (put This dsc (rdr (rd len)))
                   )))
    (lang~dolist parser (schema This))
    rem
    ))

################################################################################
# Schema validation
################################################################################

(de assert-size ("LAYER" "SIZE")
  (let (adder '((acc elm) (+ acc (abs (cadr elm))))
        sze   (lang~foldl adder 0 (schema "LAYER"))
        iden  (car (str "LAYER")))
    (when (<> "SIZE" sze)
      (quit (pack "Size for " iden " is " sze ", expected to be " "SIZE")))))
