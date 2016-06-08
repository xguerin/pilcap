#
# Note: please load lib/serializable.l in the top level first !
#
(symbols 'netstack 'serializable)

(load "lib/netutils.l")

# Layer class

(class +Layer +Serializable)

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
    (if "APP" (foldl (serializable~parse (new "APP")) "CB" "APP" "ACC") nac)
    ))

(dm foldr ("CB" "APP" "ACC")
  (let (fut (if "APP" (foldr (serializable~parse (new "APP")) "CB" "APP" "ACC") "ACC")
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
    (if "APP" (foldl (serializable~parse (new "APP")) "CB" "APP" "ACC") nac)
    ))

(dm foldr ("CB" "APP" "ACC")
  (let (fut (if "APP" (foldr (serializable~parse (new "APP")) "CB" "APP" "ACC") "ACC")
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
      (6  (foldl (serializable~parse (new '(+TCP))) "CB" "APP" nac))
      (17 (foldl (serializable~parse (new '(+UDP))) "CB" "APP" nac))
      (T  nac)
      )))

(dm foldr ("CB" "APP" "ACC")
  (let (fut (case (: proto)
              (6  (foldr (serializable~parse (new '(+TCP))) "CB" "APP" "ACC"))
              (17 (foldr (serializable~parse (new '(+UDP))) "CB" "APP" "ACC"))
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
      ("0800" (foldl (serializable~parse (new '(+IPv4))) "CB" "APP" nac))
      ("8100" (foldl (serializable~parse (new '(+Vlan))) "CB" "APP" nac))
      (T      nac)
      )))

(dm foldr ("CB" "APP" "ACC")
  (let (fut (case (pad 4 (hex (: type)))
              ("0800" (foldr (serializable~parse (new '(+IPv4))) "CB" "APP" "ACC"))
              ("8100" (foldr (serializable~parse (new '(+Vlan))) "CB" "APP" "ACC"))
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
      ("0800" (foldl (serializable~parse (new '(+IPv4))) "CB" "APP" nac))
      ("8100" (foldl (serializable~parse (new '(+Vlan))) "CB" "APP" nac))
      (T      nac)
      )))

(dm foldr ("CB" "APP" "ACC")
  (let (fut (case (pad 4 (hex (: type)))
              ("0800" (foldr (serializable~parse (new '(+IPv4))) "CB" "APP" "ACC"))
              ("8100" (foldr (serializable~parse (new '(+Vlan))) "CB" "APP" "ACC"))
              (T      "ACC"))
        nxt ("CB" This (cadr fut))
        sze (+ (car fut) (len This)))
    (list sze nxt)))

# Generic inspector

(de packet-foldl ("CB" "APP" "ACC")
  (let (layer (serializable~parse (new '(+Ethernet))))
    (foldl layer "CB" "APP" "ACC")))

(de packet-foldr ("CB" "APP" "ACC")
  (let (layer (serializable~parse (new '(+Ethernet))))
    (foldr layer "CB" "APP" "ACC")))

