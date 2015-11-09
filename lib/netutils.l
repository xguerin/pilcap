(symbols 'netutils 'pico)

(load "@lib/misc.l")
(load "lib/lang.l")

(de ipv4 ("VAL")
  (cond
  ((str? "VAL")
    (let (tokz  '((s) (mapcar pack (split (chop s) ".")))
          toks  (tokenize "VAL")
          nums  (mapcar format toks)
          expn  '((acc vl) (>> (- (* 8 (length acc))) vl))
          shft  (lang~foldr '((x acc) (append (list (expn acc x)) acc)) nums ()))
      (lang~foldl '((acc x) (| acc x)) 0 shft)))
  ((num? "VAL")
    (let  (nums (make
                  (link (>> 24 (& "VAL" (hex "FF000000"))))
                  (link (>> 16 (& "VAL" (hex "FF0000"))))
                  (link (>>  8 (& "VAL" (hex "FF00"))))
                  (link        (& "VAL" (hex "FF"))))
            toks (mapcar format nums))
    (glue "." toks)))
  (T NIL)))
