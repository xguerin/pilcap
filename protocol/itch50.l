(symbols 'itch50 'netstack)

(load "@lib/misc.l")

# Higher level messages

(class +AddOrder +Layer)

(dm schema ()
  '((2  stock_locate  "0x"  hex) 
    (2  track_number  "0x"  hex)
    (6  nanos         "0x"  hex)
    (8  refnum        "0x"  hex)
    (1  type          "0x"  hex)
    (4  qty           "0x"  hex)
    (8  symbol        "0x"  hex)
    (4  price         "0x"  hex)))

(class +ExecOrder +Layer)

(dm schema ()
  '((2  stock_locate  "0x"  hex)
    (2  track_number  "0x"  hex)
    (6  nanos         "0x"  hex)
    (8  refnum        "0x"  hex)
    (4  qty           "0x"  hex)
    (8  matchnum      "0x"  hex)))

# Header class

(class +Header +Layer)

(dm schema ()
  '((2  length  ""    format)
    (1  type    "0x"  hex)))

(dm insp ("CB" "ACC")
  (let (nxt ("CB" This (cadr "ACC"))
        sze (+ (car "ACC") (len This))
        nac (list sze nxt))
    (case (char (: type))
      ("A"
            (insp (new '(+AddOrder)) "CB" "ACC"))
      ("E"
            (insp (new '(+ExecOrder)) "CB" "ACC"))
      (T    (let  (rem  (dec (: length)))
              (rd rem)
              (cons (+ rem (car nac)) (cdr nac))))
    )))

# UFO class

(class +UFO +Layer)

(dm schema ()
  '((10 session "0x"  hex)
    (8  seqnum  ""    format)
    (2  count   ""    format)))

(dm insp ("CB" "ACC")
  (let (nxt ("CB" This (cadr "ACC"))
        sze (+ (car "ACC") (len This))
        nac (list sze nxt))
    (if (and (> (: count) 0) (< (: count) 65535))
      (do (: count)
        (insp (new '(+Header)) "CB" "ACC"))
      nac
    )))

# Entry point

(de entrypoint () '(+UFO))
