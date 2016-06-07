(symbols 'itch50 'netstack)

# System event

(class +Itch50SysEvent +Layer)

(dm schema ()
  '((1  msgtype)
    (2  stock_locate)
    (2  tracking_number)
    (6  nanos)
    (1  code)))

(assert-size '+Itch50SysEvent 12)

# Stock dir

(class +Itch50StockDir +Layer)

(dm schema ()
  '((1  msgtype)
    (2  stock_locate)
    (2  tracking_number)
    (6  nanos)
    (8  symbol)
    (1  category)
    (1  finStatus)
    (4  lotSize)
    (1  roundOnly)
    (1  issue_structification)
    (2  issue_subtype)
    (1  authenticity)
    (1  short_sale_threshold)
    (1  ipo_flag)
    (1  luld_reference_price)
    (1  etp_flag)
    (4  etp_leverage)
    (1  inverse_indicator)))

(assert-size '+Itch50StockDir 39)

# Stock act

(class +Itch50StockAct +Layer)

(dm schema ()
  '((1  msgtype)
    (2  stock_locate)
    (2  tracking_number)
    (6  nanos)
    (8  symbol)
    (1  state)
    (1  _padding_)
    (4  reason)))

(assert-size '+Itch50StockAct 25)

# Reg SHOR

(class +Itch50RegSHORstr +Layer)

(dm schema ()
  '((1  msgtype)
    (2  stock_locate)
    (2  tracking_number)
    (6  nanos)
    (8  symbol)
    (1  action)))

(assert-size '+Itch50RegSHORstr 20)

# Market position

(class +Itch50MktPrtPos +Layer)

(dm schema ()
  '((1  msgtype)
    (2  stock_locate)
    (2  tracking_number)
    (6  nanos)
    (4  mpid)
    (8  symbol)
    (1  primary)
    (1  mode)
    (1  state)))

(assert-size '+Itch50MktPrtPos 26)

# Add order

(class +Itch50AddOrder +Layer)

(dm schema ()
  '((2  stock_locate)
    (2  track_number)
    (6  nanos)
    (8  refnum)
    (1  type)
    (4  qty)
    (8  symbol)
    (4  price)))

(assert-size '+Itch50AddOrder 35)

# Add order MPID

(class +Itch50AddOrdMPID +Layer)

(dm schema()
  '((1  msgtype)
    (2  stock_locate)
    (2  tracking_number)
    (6  nanos)
    (8  refnum)
    (1  type)
    (4  qty)
    (8  symbol)
    (3  price)
    (4  mpid)))

(assert-size '+Itch50AddOrdMPID 39)

# Exec order

(class +Itch50ExecOrder +Layer)

(dm schema ()
  '((2  stock_locate)
    (2  track_number)
    (6  nanos)
    (8  refnum)
    (4  qty)
    (8  matchnum)))

(assert-size '+Itch50ExecOrder 30)

# Exec order PX

(class +Itch50ExecOrdPx +Layer)

(dm schema ()
  '((1  msgtype)
    (2  stock_locate)
    (2  tracking_number)
    (6  nanos)
    (8  refnum)
    (4  qty)
    (8  matchnum)
    (1  print)
    (4  price)))

(assert-size '+Itch50ExecOrdPx 36)

# Cancel order

(class +Itch50CxlOrd +Layer)

(dm schema ()
  '((1  msgtype)
    (2  stock_locate)
    (2  tracking_number)
    (6  nanos)
    (8  refnum)
    (4  qty)))

(assert-size '+Itch50CxlOrd 23)

# Del order

(class +Itch50DelOrd +Layer)

(dm schema ()
  '((1  msgtype)
    (2  stock_locate)
    (2  tracking_number)
    (6  nanos)
    (8  refnum)))

(assert-size '+Itch50DelOrd 19)

# Cancel replace

(class +Itch50CxlRepOrd +Layer)

(dm schema ()
  '((1  msgtype)
    (2  stock_locate)
    (2  tracking_number)
    (6  nanos)
    (8  oldref)
    (8  newref)
    (4  qty)
    (4  price)))
 
(assert-size '+Itch50CxlRepOrd 35)

# Hdn Exec

(class +Itch50HdnExec +Layer)

(dm schema ()
  '((1  msgtype)
    (2  stock_locate)
    (2  tracking_number)
    (6  nanos)
    (8  refnum)
    (1  type)
    (4  qty)
    (8  symbol)
    (4  price)
    (8  matchnum)))

(assert-size '+Itch50HdnExec 44)

# Cross trade

(class +Itch50CrossTrd +Layer)

(dm schema ()
  '((1  msgtype)
    (2  stock_locate)
    (2  tracking_number)
    (6  nanos)
    (8  qty)
    (8  symbol)
    (4  price)
    (8  matchnum)
    (1  crossType)))

(assert-size '+Itch50CrossTrd 40)

# Broken trade

(class +Itch50BrokenTrd +Layer)

(dm schema ()
  '((1  msgtype)
    (2  stock_locate)
    (2  tracking_number)
    (6  nanos)
    (8  matchnum)))

(assert-size '+Itch50BrokenTrd 19)

# Imbalance

(class +Itch50Imbalance +Layer)

(dm schema ()
  '((1  msgtype)
    (2  stock_locate)
    (2  tracking_number)
    (6  nanos)
    (8  pairQty)
    (8  imbQty)
    (1  imbDir)
    (8  symbol)
    (4  farPrice)
    (4  nearPrice)
    (4  refPrice)
    (1  crossType)
    (1  priceVar)))

(assert-size '+Itch50Imbalance 50)

# Interest

(class +Itch50Interest +Layer)

(dm schema ()
  '((1  msgtype)
    (2  stock_locate)
    (2  tracking_number)
    (6  nanos)
    (8  symbol)
    (1  interestFlag)))

(assert-size '+Itch50Interest 20)

# MWCB

(class +Itch50MWCB +Layer)

(dm schema ()
  '((1  msgtype)
    (2  stock_locate)
    (2  tracking_number)
    (6  nanos)
    (8  level1)
    (8  level2)
    (8  level3)))

(assert-size '+Itch50MWCB 35)

# IPO quote

(class +Itch50IPOQuote +Layer)

(dm schema ()
  '((1  msgtype)
    (2  stock_locate)
    (2  tracking_number)
    (6  nanos)
    (1  symbol)
    (4  release_time)
    (1  release_qualifier)
    (4  price)))

(assert-size '+Itch50IPOQuote 21)

# Header class

(class +Itch50Header +Layer)

(dm schema ()
  '((2  length  ""    format)
    (1  type    "0x"  hex)))

(dm insp ("CB" "APP" "ACC")
  (let (nxt ("CB" This (cadr "ACC"))
            sze (+ (car "ACC") (len This))
            nac (list sze nxt))
    (case (char (: type))
          ("A"  (insp (new '(+Itch50AddOrder)) "CB" "APP" "ACC"))
          ("E"  (insp (new '(+Itch50ExecOrder)) "CB" "APP" "ACC"))
          (T  (let  (rem  (dec (: length)))
                (rd rem)
                (list (+ rem (car nac)) (cdr nac))))
          )))

(dm foldl ("CB" "APP" "ACC")
  (let (nxt ("CB" This (cadr "ACC"))
            sze (+ (car "ACC") (len This))
            nac (list sze nxt))
    (case (char (: type))
          ("A"  (foldl (new '(+Itch50AddOrder)) "CB" "APP" "ACC"))
          ("E"  (foldl (new '(+Itch50ExecOrder)) "CB" "APP" "ACC"))
          (T  (let  (rem  (dec (: length)))
                (rd rem)
                (list (+ rem (car nac)) (cdr nac))))
          )))

(dm foldr ("CB" "APP" "ACC")
  (let (fut (case (char (: type))
                  ("A"  (foldr (new '(+Itch50AddOrder)) "CB" "APP" "ACC"))
                  ("E"  (foldr (new '(+Itch50ExecOrder)) "CB" "APP" "ACC"))
                  (T  (let  (rem  (dec (: length)))
                        (rd rem)
                        (list (+ rem (car nac)) (cdr nac)))))
            nxt ("CB" This (cadr fut))
            sze (+ (car fut) (len This)))
    (list sze nxt)
    ))

# UFO class

(class +UFO +Layer)

(dm schema ()
  '((10 session)
    (8  seqnum  ""    format)
    (2  count   ""    format)))

(dm foldl ("CB" "APP" "ACC")
  (let (nxt ("CB" This (cadr "ACC"))
            sze (+ (car "ACC") (len This))
            nac (list sze nxt))
    (when (and (> (: count) 0) (< (: count) 65535))
          (do (: count)
              (setq nac (foldl (new '(+Itch50Header)) "CB" "APP" nac))))
    nac
    ))

(dm foldr ("CB" "APP" "ACC")
  (let (tmp "ACC")
    (when (and (> (: count) 0) (< (: count) 65535))
          (do (: count)
              (setq tmp (foldr (new '(+Itch50Header)) "CB" "APP" tmp))))
    (let (nxt ("CB" This (cadr tmp))
              sze (+ (car tmp) (len This)))
      (list sze nxt)
      )))

# Entry point

(de entrypoint () '(+UFO))
