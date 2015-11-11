(symbols 'itch50 'netstack)

(load "@lib/misc.l")

# Higher level messages

(class +Itch50AddOrder +Layer)

(dm schema ()
  '((2  stock_locate  "0x"  hex) 
    (2  track_number  "0x"  hex)
    (6  nanos         "0x"  hex)
    (8  refnum        "0x"  hex)
    (1  type          "0x"  hex)
    (4  qty           "0x"  hex)
    (8  symbol        "0x"  hex)
    (4  price         "0x"  hex)))

(class +Itch50ExecOrder +Layer)

(dm schema ()
  '((2  stock_locate  "0x"  hex)
    (2  track_number  "0x"  hex)
    (6  nanos         "0x"  hex)
    (8  refnum        "0x"  hex)
    (4  qty           "0x"  hex)
    (8  matchnum      "0x"  hex)))

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
  '((10 session "0x"  hex)
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
