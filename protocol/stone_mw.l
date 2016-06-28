(symbols 'stone_mw 'netstack)

(load "lib/lang.l")

################################################################################
# Bit layer class
################################################################################

(class +BitLayer)

(dm ident ()
  (pack (cdr (chop (name (car (type This)))))))

(dm len ()
  (lang~foldl
    '((acc e) (+ acc (abs (cadr e))))
    0
    (schema This)))

(dm display ()
  (let (writer  '((elt)
                  (let ((dsc len NIL NIL) elt
                        nam               (name dsc))
                    (prinl "| " (align -22 nam) " : " (get This dsc))
                    )))
    (lang~dolist writer (schema This))
    ))

(dm parse ("VAL")
  (let (cur     0
        parser '((elt)
                 (let ((dsc bln NIL rdr)  elt
                       msk                (- (>> (- bln) 1) 1)
                       shf                (- (len This) (+ cur bln)))
                   (default rdr lang~identity)
                   (put This dsc (rdr (& (>> shf "VAL") msk)))
                   (inc 'cur bln)
                   )))
    (lang~dolist parser (schema This))
    (len This)
    ))

(dm foldl ("FUN" "ACC")
  (let (acc ("FUN" "ACC" This))
    (if (: next>)
      (foldl (: next>) "FUN" acc)
      acc)
    ))

(dm foldr ("FUN" "ACC")
  (let (fut (if (: next>)
              (foldr (: next>) "FUN" "ACC")
              "ACC"))
    ("FUN" This fut)
    ))

################################################################################
# Packet skip class
################################################################################

(class +PackedSkip +BitLayer)

(dm schema ()
  '((typ 3)
    (cnt 3)
    ))

################################################################################
# Packed tick class
################################################################################

(class +PackedTick +BitLayer)

(dm schema ()
  '((typ   3)
    (sid   1)
    (siz  12)
    (dlt   4)
    (swp   1)
    ))

################################################################################
# Packed first class
################################################################################

(class +PackedFirst +BitLayer)

(dm schema ()
  '((typ   3)
    (sid   1)
    (cnt   3)
    (siz  12)
    (dlt  12)
    (swp   1)
    ))

################################################################################
# Packet header class
################################################################################

(class +STONE_MW +Layer)

(dm T ()
  (=: data 0)
  (=: dlen 0))

(dm schema ()
  '((header  2)
    ))

(assert-size '+STONE_MW 2)

(dm get_type ("CUR")
  (let (rev (>> -3 (: dlen))
        shf (- rev (+ "CUR" 3))
        svl (>> shf (: data)))
    (& svl 7)
    ))

(dm get_next ("CUR" "SZE")
  (let (rev (>> -3 (: dlen))
        shf (- rev (+ "CUR" "SZE"))
        msk (- (>> (- "SZE") 1) 1)
        svl (>> shf (: data)))
    (& svl msk)
    ))

(dm parse ("LENGTH" "APP")
  (let (rem (super "LENGTH" "APP")
        dln (- "LENGTH" 2)
        dat (rd dln)
        bln (>> -3 dln)
        cur 0)
    (=: data dat)
    (=: dlen dln)
    (while (> (- bln cur) 6)
      (case (get_type This cur)
        (0  (let (dat (get_next This cur 6)
                  nxt (new '(+PackedSkip)))
              (inc 'cur (parse nxt dat))
              (=: next> (append (: next>) (list nxt)))
              ))
        (1  (let (dat (get_next This cur 21)
                  nxt (new '(+PackedTick)))
              (inc 'cur (parse nxt dat))
              (=: next> (append (: next>) (list nxt)))
              ))
        (3  (let (dat (get_next This cur 32)
                  nxt (new '(+PackedFirst)))
              (inc 'cur (parse nxt dat))
              (=: next> (append (: next>) (list nxt)))
              ))
        )))
  0)

(dm foldl ("FUN" "ACC")
  (let (acc  ("FUN" "ACC" This)
        insp '((acc elm)
               (conc acc (foldl elm "FUN" NIL))
               ))
    (lang~foldl insp acc (: next>))
    ))

(dm foldr ("FUN" "ACC")
  (let (insp  '((acc elm)
                (cons (foldr elm "FUN" NIL) acc))
        acc   (lang~foldl insp "ACC" (: next>)))
    ("FUN" This acc)
    ))

################################################################################
# Entry point
################################################################################

(de entrypoint () '(+STONE_MW))
