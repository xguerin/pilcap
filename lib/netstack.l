(symbols 'netstack 'pico)

(load "@lib/misc.l")
(load "lib/netutils.l")
(load "lib/lang.l")

# Layer class

(class +Layer)

(dm T ()
  (let (reader  '((e)
                  (let (s   (car e)
                        n   (name s)
                        p   (cadr e))
                    (put This s (rd p)))))
    (mapc reader (schema This))))

(dm dump ()
  (let (writer  '((e)
                  (let (s   (car e)
                        n   (name s)
                        p   (* 2 (cadr e))
                        pfx (caddr e)
                        fmt (cadddr e))
                    (prinl "| " (align -14 n) " : " pfx (pad p (fmt (get This s)))))))
    (mapc writer (schema This))))

(dm len ()
  (lang~foldl '((acc e) (+ acc (cadr e) )) 0 (schema This)))

(dm ident ()
  (pack (cdr (chop (name (car (type This)))))))

(dm insp ("CB" "ACC")
  (+ ("CB" This "ACC") (len This)))

# TCP Layer

(class +TCP +Layer)

(dm schema ()
  '((src      2 "h'"  hex)
    (dst      2 "h'"  hex)
    (seqnum   4 "d'"  format)
    (acknum   4 "d'"  format)
    (flags    2 "h'"  hex)
    (winsize  2 "d'"  format)
    (chksum   2 "h'"  hex)
    (urgptr   2 "h'"  hex)))

# UDP

(class +UDP +Layer)

(dm schema ()
  '((src    2 "d'"  format)
    (dst    2 "h'"  format)
    (len    2 "h'"  format)
    (chksum 2 "h'"  hex)))

# IP Layer

(class +IPv4 +Layer)

(dm schema ()
	'((flags  2 "h'" hex)
	  (len 	  2 "d'" format)
	  (ident  2 "h'" hex)
	  (frag	  2 "h'" hex)
	  (ttl 	  1 "h'" hex)
	  (proto  1 "h'" hex)
	  (chksum 2 "h'" hex)
	  (src	  4 "h'" hex)
	  (dst	  4 "h'" hex)))

(dm insp ("CB" "ACC")
  ("CB" This "ACC")
  (case (: proto)
    (6
      (let (layer (new '(+TCP)))
        (+ (insp layer "CB" "ACC") (len This))))
    (17
      (let (layer (new '(+UDP)))
        (+ (insp layer "CB" "ACC") (len This))))
    (T
      (let (layer (new '(+Anonymous)))
        (+ (insp layer "CB" "ACC") (len This))))
  ))

# VLAN layer

(class +vLan +Layer)

(dm schema ()
  '((tci  2 "h'" hex)
    (type 2 "h'" hex)))

(dm insp ("CB" "ACC")
  ("CB" This "ACC")
  (case (pad 4 (hex (: type)))
    ("0800"
      (let (layer (new '(+IPv4)))
        (+ (insp layer "CB" "ACC") (len This))))
    (T
      (let (layer (new '(+Anonymous)))
        (+ (insp layer "CB" "ACC") (len This))))
  ))

# Ethernet layer

(class +Ethernet +Layer)

(dm schema ()
	'((dst  6 "h'" hex)
	  (src  6 "h'" hex)
	  (type 2 "h'" hex)))

(dm insp ("CB" "ACC")
  ("CB" This "ACC")
  (case (pad 4 (hex (: type)))
    ("0800"
      (let (layer (new '(+IPv4)))
        (+ (insp layer "CB" "ACC") (len This))))
    ("8100"
      (let (layer (new '(+vLan)))
        (+ (insp layer "CB" "ACC") (len This))))
    (T
      (let (layer (new '(+Anonymous)))
        (+ (insp layer "CB" "ACC") (len This))))
  ))

# Generic inspector

(de inspect ("CB" "ACC")
  (let (layer (new '(+Ethernet)))
    (insp layer "CB" "ACC")))
