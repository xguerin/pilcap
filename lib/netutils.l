(symbols 'netutils 'pico)
(local format-addr)

(load "@lib/misc.l")
(load "lib/lang.l")

(de format-addr ("VAL" "LEN" "SEP" "FORMATTER" "PAD")
  (cond
  ((str? "VAL")
    (let (tokz  '((s) (mapcar pack (split (chop s) "SEP")))
          toks  (tokz "VAL")
          nums  (mapcar "FORMATTER" toks)
          expn  '((acc vl) (>> (- (* 8 (length acc))) vl))
          shft  (lang~foldr '((x acc) (append (list (expn acc x)) acc)) nums ()))
      (lang~foldl '((acc x) (| acc x)) 0 shft)))
  ((num? "VAL")
    (let  (nums (make
                  (for N "LEN"
                    (let (qty (* 8 (- "LEN" N)))
                      (link (>> qty (& "VAL" (>> (- qty) 255)))))))
            toks (mapcar '((n) (pad "PAD" ("FORMATTER" n))) nums))
      (glue "SEP" toks)))
  (T NIL)))

(de mac ("VAL")
  (format-addr "VAL" 6 ":" 'hex 2))

(de ipv4 ("VAL")
  (format-addr "VAL" 4 "." 'format 3))

