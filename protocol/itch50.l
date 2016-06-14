(symbols 'itch50 'netstack)

# System event

(class +Itch50SysEvent +Layer)

(dm schema ()
  '((msgtype          1)
    (stock_locate     2)
    (tracking_number  2)
    (nanos            6)
    (code             1)
    ))

(assert-size '+Itch50SysEvent 12)

# Stock dir

(class +Itch50StockDir +Layer)

(dm schema ()
  '((msgtype                1)
    (stock_locate           2)
    (tracking_number        2)
    (nanos                  6)
    (symbol                 8)
    (category               1)
    (finStatus              1)
    (lotSize                4)
    (roundOnly              1)
    (issue_structification  1)
    (issue_subtype          2)
    (authenticity           1)
    (short_sale_threshold   1)
    (ipo_flag               1)
    (luld_reference_price   1)
    (etp_flag               1)
    (etp_leverage           4)
    (inverse_indicator      1)
    ))

(assert-size '+Itch50StockDir 39)

# Stock act

(class +Itch50StockAct +Layer)

(dm schema ()
  '((msgtype          1)
    (stock_locate     2)
    (tracking_number  2)
    (nanos            6)
    (symbol           8)
    (state            1)
    (_padding_        1)
    (reason           4)
    ))

(assert-size '+Itch50StockAct 25)

# Reg SHOR

(class +Itch50RegSHORstr +Layer)

(dm schema ()
  '((msgtype          1)
    (stock_locate     2)
    (tracking_number  2)
    (nanos            6)
    (symbol           8)
    (action           1)
    ))

(assert-size '+Itch50RegSHORstr 20)

# Market position

(class +Itch50MktPrtPos +Layer)

(dm schema ()
  '((msgtype          1)
    (stock_locate     2)
    (tracking_number  2)
    (nanos            6)
    (mpid             4)
    (symbol           8)
    (primary          1)
    (mode             1)
    (state            1)
    ))

(assert-size '+Itch50MktPrtPos 26)

# Add order

(class +Itch50AddOrder +Layer)

(dm schema ()
  '((stock_locate 2)
    (track_number 2)
    (nanos        6)
    (refnum       8)
    (type         1)
    (qty          4)
    (symbol       8)
    (price        4)
    ))

(assert-size '+Itch50AddOrder 35)

# Add order MPID

(class +Itch50AddOrdMPID +Layer)

(dm schema()
  '((msgtype          1)
    (stock_locate     2)
    (tracking_number  2)
    (nanos            6)
    (refnum           8)
    (type             1)
    (qty              4)
    (symbol           8)
    (price            3)
    (mpid             4)
    ))

(assert-size '+Itch50AddOrdMPID 39)

# Exec order

(class +Itch50ExecOrder +Layer)

(dm schema ()
  '((stock_locate 2)
    (track_number 2)
    (nanos        6)
    (refnum       8)
    (qty          4)
    (matchnum     8)
    ))

(assert-size '+Itch50ExecOrder 30)

# Exec order PX

(class +Itch50ExecOrdPx +Layer)

(dm schema ()
  '((msgtype          1)
    (stock_locate     2)
    (tracking_number  2)
    (nanos            6)
    (refnum           8)
    (qty              4)
    (matchnum         8)
    (print            1)
    (price            4)
    ))

(assert-size '+Itch50ExecOrdPx 36)

# Cancel order

(class +Itch50CxlOrd +Layer)

(dm schema ()
  '((msgtype          1)
    (stock_locate     2)
    (tracking_number  2)
    (nanos            6)
    (refnum           8)
    (qty              4)
    ))

(assert-size '+Itch50CxlOrd 23)

# Del order

(class +Itch50DelOrd +Layer)

(dm schema ()
  '((msgtype          1)
    (stock_locate     2)
    (tracking_number  2)
    (nanos            6)
    (refnum           8)
    ))

(assert-size '+Itch50DelOrd 19)

# Cancel replace

(class +Itch50CxlRepOrd +Layer)

(dm schema ()
  '((msgtype          1)
    (stock_locate     2)
    (tracking_number  2)
    (nanos            6)
    (oldref           8)
    (newref           8)
    (qty              4)
    (price            4)
    ))
 
(assert-size '+Itch50CxlRepOrd 35)

# Hdn Exec

(class +Itch50HdnExec +Layer)

(dm schema ()
  '((msgtype          1)
    (stock_locate     2)
    (tracking_number  2)
    (nanos            6)
    (refnum           8)
    (type             1)
    (qty              4)
    (symbol           8)
    (price            4)
    (matchnum         8)
    ))

(assert-size '+Itch50HdnExec 44)

# Cross trade

(class +Itch50CrossTrd +Layer)

(dm schema ()
  '((msgtype          1)
    (stock_locate     2)
    (tracking_number  2)
    (nanos            6)
    (qty              8)
    (symbol           8)
    (price            4)
    (matchnum         8)
    (crossType        1)
    ))

(assert-size '+Itch50CrossTrd 40)

# Broken trade

(class +Itch50BrokenTrd +Layer)

(dm schema ()
  '((msgtype          1)
    (stock_locate     2)
    (tracking_number  2)
    (nanos            6)
    (matchnum         8)
    ))

(assert-size '+Itch50BrokenTrd 19)

# Imbalance

(class +Itch50Imbalance +Layer)

(dm schema ()
  '((msgtype          1)
    (stock_locate     2)
    (tracking_number  2)
    (nanos            6)
    (pairQty          8)
    (imbQty           8)
    (imbDir           1)
    (symbol           8)
    (farPrice         4)
    (nearPrice        4)
    (refPrice         4)
    (crossType        1)
    (priceVar         1)
    ))

(assert-size '+Itch50Imbalance 50)

# Interest

(class +Itch50Interest +Layer)

(dm schema ()
  '((msgtype          1)
    (stock_locate     2)
    (tracking_number  2)
    (nanos            6)
    (symbol           8)
    (interestFlag     1)
    ))

(assert-size '+Itch50Interest 20)

# MWCB

(class +Itch50MWCB +Layer)

(dm schema ()
  '((msgtype          1)
    (stock_locate     2)
    (tracking_number  2)
    (nanos            6)
    (level1           8)
    (level2           8)
    (level3           8)
    ))

(assert-size '+Itch50MWCB 35)

# IPO quote

(class +Itch50IPOQuote +Layer)

(dm schema ()
  '((msgtype            1)
    (stock_locate       2)
    (tracking_number    2)
    (nanos              6)
    (symbol             1)
    (release_time       4)
    (release_qualifier  1)
    (price              4)
    ))

(assert-size '+Itch50IPOQuote 21)

# Header class

(class +Itch50Header +Layer)

(dm schema ()
  '((length 2)
    (type   1)
    ))

(assert-size '+Itch50Header 3)

(dm msg_len ()
  (- (: length) 1))

(dm get_message_type ()
  (case (char (: type))
    ("A"  '(+Itch50AddOrder))
    ("E"  '(+Itch50ExecOrder))
    (T    NIL)
    ))

(dm parse ("LENGTH" "APP")
  (let (rem     (super "LENGTH" "APP")
        message (get_message_type This))
    (if message
      (let (nxt (new message)
            len (parse nxt (msg_len This) "APP"))
        (=: next> nxt)
        (rd len)
        (setq rem (- rem (msg_len This))))
      (prog
        (setq rem (- rem (msg_len This)))
        (rd (msg_len This))))
    rem
    ))

# UFO class

(class +UFO +Layer)

(dm schema ()
  '((session  10)
    (seqnum   8)
    (count    2)))

(dm parse ("LENGTH" "APP")
  (let (rem (super "LENGTH" "APP"))
    (when (and (> (: count) 0) (< (: count) 65535))
      (do (: count)
        (let (nxt (new '(+Itch50Header))
              len (parse nxt rem "APP"))
          (=: next> (cons nxt (: next>)))
          (setq rem len)
          )))
    (rd rem)
    0
    ))

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

# Entry point

(de entrypoint () '(+UFO))
