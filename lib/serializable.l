(symbols 'serializable 'pico)

(load "lib/lang.l")

# Serializable class

(class +Serializable)

(dm parse ()
  (let (parser '((e)
                 (let ((len dsc) e)
                   (put This dsc (rd len))
                   )))
    (lang~dolist parser (schema This))
    This
    ))

(dm dump ()
  (let (getter '((e)
                 (let ((len dsc) e)
                   (lang~nwr (list len (get This dsc)))
                   )))
    (lang~dolist getter (schema This))
    This
    ))

(dm display ()
  (let (writer  '((e)
                  (let ((len dsc) e
                        nam (name dsc)
                        wdh (* 2 len)
                        pfx (or (caddr e) "0x")
                        fmt (or (cadddr e) hex))
                    (prinl "| " (align -14 nam) " : " pfx (pad wdh (fmt (get This dsc))))
                    )))
    (lang~dolist writer (schema This))
    ))

(dm expand ()
  (let (builder '((e)
                  (let ((len dsc) e
                        nam (name dsc)
                        wdh (* 2 len)
                        pfx (or (caddr e) "0x")
                        fmt (or (cadddr e) hex)
                        res (pack pfx (pad len (fmt (get This dsc)))))
                    (link (cons nam res)))))
    (make (lang~dolist builder (schema This)))
    ))

(dm len ()
  (lang~foldl '((acc e) (+ acc (car e) )) 0 (schema This)))

# Schema validation

(de assert-size ("LAYER" "SIZE")
  (let (adder '((acc elm) (+ acc (car elm)))
        sze   (lang~foldl adder 0 (schema "LAYER"))
        iden  (car (str "LAYER")))
    (when (<> "SIZE" sze)
      (quit (pack "Size for " iden " is " sze ", expected to be " "SIZE")))))
