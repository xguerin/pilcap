(symbols 'netstack 'pico)

(load "@lib/misc.l")
(load "lib/lang.l")
(load "lib/netutils.l")

# Layer class

(class +Layer)

(dm T ()
  (let (reader  '((e)
                  (let (len (car e)
                            dsc (cadr e))
                    (put This dsc (rd len))
                    )))
    (lang~dolist reader (schema This))
    ))

(dm dump ()
  (let (writer  '((e)
                  (let (len (car e)
                            dsc (cadr e)
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
                  (let (len (car e)
                            dsc (cadr e)
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

(dm ident ()
  (pack (cdr (chop (name (car (type This)))))))

(dm foldl ("CB" "APP" "ACC")
  (list (+ (car "ACC") (len This)) ("CB" This (cadr "ACC"))))

(dm foldr ("CB" "APP" "ACC")
  (list (+ (car "ACC") (len This)) ("CB" This (cadr "ACC"))))

# TCP Layer

(class +TCP +Layer)

(dm schema ()
  '((2  src     "0x"  hex)
    (2  dst     "0x"  hex)
    (4  seqnum  ""    format)
    (4  acknum  ""    format)
    (2  flags   "0x"  hex)
    (2  winsize ""    format)
    (2  chksum  "0x"  hex)
    (2  urgptr  "0x"  hex)))

(dm foldl ("CB" "APP" "ACC")
  (let (nxt ("CB" This (cadr "ACC"))
            sze (+ (car "ACC") (len This))
            nac (list sze nxt) )
    (if "APP" (foldl (new "APP") "CB" "APP" "ACC") nac)
    ))

(dm foldr ("CB" "APP" "ACC")
  (let (fut (if "APP" (foldr (new "APP") "CB" "APP" "ACC") "ACC")
            nxt ("CB" This (cadr fut))
            sze (+ (car fut) (len This)))
    (list sze nxt)))

# UDP

(class +UDP +Layer)

(dm schema ()
  '((2  src     ""    format)
    (2  dst     ""    format)
    (2  len     ""    format)
    (2  chksum  "0x"  hex)))

(dm foldl ("CB" "APP" "ACC")
  (let (nxt ("CB" This (cadr "ACC"))
            sze (+ (car "ACC") (len This))
            nac (list sze nxt) )
    (if "APP" (foldl (new "APP") "CB" "APP" "ACC") nac)
    ))

(dm foldr ("CB" "APP" "ACC")
  (let (fut (if "APP" (foldr (new "APP") "CB" "APP" "ACC") "ACC")
            nxt ("CB" This (cadr fut))
            sze (+ (car fut) (len This)))
    (list sze nxt)))

# IP Layer

(class +IPv4 +Layer)

(dm schema ()
  '((2  flags   "0x"  hex)
    (2  len 	  ""    format)
    (2  ident   "0x"  hex)
    (2  frag	  "0x"  hex)
    (1  ttl 	  "0x"  hex)
    (1  proto   "0x"  hex)
    (2  chksum  "0x"  hex)
    (4  src	    "0x"  hex)
    (4  dst	    "0x"  hex)))

(dm foldl ("CB" "APP" "ACC")
  (let (nxt ("CB" This (cadr "ACC"))
            sze (+ (car "ACC") (len This))
            nac (list sze nxt))
    (case (: proto)
          (6  (foldl (new '(+TCP)) "CB" "APP" nac))
          (17 (foldl (new '(+UDP)) "CB" "APP" nac))
          (T  nac)
          )))

(dm foldr ("CB" "APP" "ACC")
  (let (fut (case (: proto)
                  (6  (foldr (new '(+TCP)) "CB" "APP" "ACC"))
                  (17 (foldr (new '(+UDP)) "CB" "APP" "ACC"))
                  (T  "ACC"))
            nxt ("CB" This (cadr fut))
            sze (+ (car fut) (len This)))
    (list sze nxt)))

# VLAN layer

(class +Vlan +Layer)

(dm schema ()
  '((2  tci   "0x"  hex)
    (2  type  "0x"  hex)))

(dm foldl ("CB" "APP" "ACC")
  (let (nxt ("CB" This (cadr "ACC"))
        sze (+ (car "ACC") (len This))
        nac (list sze nxt))
    (case (pad 4 (hex (: type)))
          ("0800" (foldl (new '(+IPv4))  "CB" "APP" nac))
          ("8100" (foldl (new '(+Vlan))  "CB" "APP" nac))
          (T      nac)
          )))

(dm foldr ("CB" "APP" "ACC")
  (let (fut (case (pad 4 (hex (: type)))
                  ("0800" (foldr (new '(+IPv4)) "CB" "APP" "ACC"))
                  ("8100" (foldr (new '(+Vlan)) "CB" "APP" "ACC"))
                  (T      "ACC"))
        nxt ("CB" This (cadr fut))
        sze (+ (car fut) (len This)))
    (list sze nxt)))

# Ethernet layer

(class +Ethernet +Layer)

(dm schema ()
  '((6  dst   "0x"  hex)
    (6  src   "0x"  hex)
    (2  type  "0x"  hex)))

(dm foldl ("CB" "APP" "ACC")
  (let (nxt ("CB" This (cadr "ACC"))
        sze (+ (car "ACC") (len This))
        nac (list sze nxt))
    (case (pad 4 (hex (: type)))
          ("0800" (foldl (new '(+IPv4)) "CB" "APP" nac))
          ("8100" (foldl (new '(+Vlan)) "CB" "APP" nac))
          (T      nac)
          )))

(dm foldr ("CB" "APP" "ACC")
  (let (fut (case (pad 4 (hex (: type)))
                  ("0800" (foldr (new '(+IPv4)) "CB" "APP" "ACC"))
                  ("8100" (foldr (new '(+Vlan)) "CB" "APP" "ACC"))
                  (T      "ACC"))
        nxt ("CB" This (cadr fut))
        sze (+ (car fut) (len This)))
    (list sze nxt)))

# Generic inspector

(de packet-foldl ("CB" "APP" "ACC")
  (let (layer (new '(+Ethernet)))
    (foldl layer "CB" "APP" "ACC")))

(de packet-foldr ("CB" "APP" "ACC")
  (let (layer (new '(+Ethernet)))
    (foldr layer "CB" "APP" "ACC")))

(de assert-size ("LAYER" "SIZE")
  (let (adder '((acc elm) (+ acc (car elm)))
        sze   (lang~foldl adder 0 (schema "LAYER"))
        iden  (car (str "LAYER")))
    (when (<> "SIZE" sze)
          (quit (pack "Size for " iden " is " sze ", expected to be " "SIZE")))))

