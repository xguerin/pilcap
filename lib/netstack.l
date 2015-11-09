(symbols 'netstack 'pico)

(load "@lib/misc.l")
(load "lib/netutils.l")

# Payload layer

(class +Payload)

(dm insp ("CB" "ACC")
  ("CB" This "ACC") 0)

(dm dump ())

(dm ident ()  "PLD")
(dm len ()    0)

# UDP Layer

(class +TCP)

(dm T ()
  (=: _src      (rd 2))
  (=: _dst      (rd 2))
  (=: _seqnum   (rd 4))
  (=: _acknum   (rd 4))
  (=: _flags    (rd 2))
  (=: _winsize  (rd 2))
  (=: _chksum   (rd 2))
  (=: _urgptr   (rd 2)))

(dm insp ("CB" "ACC")
  ("CB" This "ACC")
  (case (: _type)
    (T
      (let (layer (new '(+Payload)))
        (+ (insp layer "CB" "ACC") (len This))))
  ))

(dm dump ()
	(prinl "src           : d"      (: _src))
	(prinl "dst           : d"      (: _dst))
	(prinl "seqnum        : d"      (: _seqnum))
	(prinl "acknum        : d"      (: _acknum))
	(prinl "flags         : h" (hex (: _flags)))
	(prinl "winsize       : d"      (: _winsize))
	(prinl "chksum        : d" (hex (: _chksum)))
	(prinl "urgptr        : h" (hex (: _urgptr)))
)

(dm ident ()  "TCP")
(dm len ()    20)

# IP Layer

(class +IPv4)

(dm T ()
	(=: _flags  (rd 2))
	(=: _len 	  (rd 2))
	(=: _ident	(rd 2))
	(=: _frag	  (rd 2))
	(=: _ttl 	  (rd 1))
	(=: _proto	(rd 1))
	(=: _chksum	(rd 2))
	(=: _src	  (rd 4))
	(=: _dst	  (rd 4))
)

(dm insp ("CB" "ACC")
  ("CB" This "ACC")
  (case (: _proto)
    (6
      (let (layer (new '(+TCP)))
        (+ (insp layer "CB" "ACC") (len This))))
    (T
      (let (layer (new '(+Payload)))
        (+ (insp layer "CB" "ACC") (len This))))
  ))

(dm dump ()
	(prinl "flags         : h" (hex (: _flags)))
	(prinl "len           : d"      (: _len))
	(prinl "ident         : h" (hex (: _ident)))
	(prinl "frag          : h" (hex (: _frag)))
	(prinl "ttl           : h" (hex (: _ttl)))
	(prinl "proto         : h" (hex (: _proto)))
	(prinl "chksum        : h" (hex (: _chksum)))
	(prinl "src           : h" (hex (: _src)) " (" (netutils~ipv4 (: _src)) ")")
	(prinl "dst           : h" (hex (: _dst)) " (" (netutils~ipv4 (: _dst)) ")"))

(dm ident ()  "IP4")
(dm len ()    20)

# VLAN layer

(class +vLan)

(dm T ()
  (=: _tci  (rd 2))
  (=: _type (rd 2)))

(dm insp ("CB" "ACC")
  ("CB" This "ACC")
  (case (hex (: _type))
    ("800"
      (let (layer (new '(+IPv4)))
        (+ (insp layer "CB" "ACC") (len This))))
    (T
      (let (layer (new '(+Payload)))
        (+ (insp layer "CB" "ACC") (len This))))
  ))

(dm dump ()
  (prinl "tci           : h" (hex (: _tci)))
  (prinl "type          : h" (hex (: _type))))

(dm ident ()  "VLN")
(dm len ()    4)

# Ethernet layer

(class +Ethernet)

(dm T ()
	(=: _dst  (rd 6))
	(=: _src 	(rd 6))
	(=: _type	(rd 2)))

(dm insp ("CB" "ACC")
  ("CB" This "ACC")
  (case (hex (: _type))
    ("0800"
      (let (layer (new '(+IPv4)))
        (+ (insp layer "CB" "ACC") (len This))))
    ("8100"
      (let (layer (new '(+vLan)))
        (+ (insp layer "CB" "ACC") (len This))))
    (T
      (let (layer (new '(+Payload)))
        (+ (insp layer "CB" "ACC") (len This))))
  ))

(dm dump ()
  (prinl "dst           : h" (hex (: _dst)))
  (prinl "src           : h" (hex (: _src)))
  (prinl "type          : h" (hex (: _type))))

(dm ident ()  "ETH")
(dm len ()    14)

# Generic inspector

(de inspect ("CB" "ACC")
  (let (layer (new '(+Ethernet)))
    (insp layer "CB" "ACC")))
