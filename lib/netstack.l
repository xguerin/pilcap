#
# Note: please load lib/serializable.l in the top level first !
#
(symbols 'netstack 'serializable)

(load "lib/netutils.l")

###############################################################################
# Layer class
###############################################################################

(class +Layer +Serializable)

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

###############################################################################
# TCP Layer
###############################################################################

(class +TCP +Layer)

(dm schema ()
  '((src      2)
    (dst      2)
    (seqnum   4)
    (acknum   4)
    (flags    2 `(printer~to_hex))
    (winsize  2)
    (chksum   2 `(printer~to_hex))
    (urgptr   2 `(printer~to_hex))
    ))

(assert-size '+TCP 20)

(dm header_len ()
  (len This))

(dm parse ("LENGTH" "APP")
  (super "LENGTH" "APP")
  (rd (- (header_len This) (len This)))
  (let (rem (- "LENGTH" (header_len This)))
    (when "APP"
      (=: next> (new "APP"))
      (setq rem (parse (: next>) rem "APP")))
    (rd rem)
    (- "LENGTH" (data_len This))
    ))

###############################################################################
# UDP layer
###############################################################################

(class +UDP +Layer)

(dm schema ()
  '((src    2)
    (dst    2)
    (len    2)
    (chksum 2 `(printer~to_hex))
    ))

(assert-size '+UDP 8)

(dm header_len ()
  (len This))

(dm data_len ()
  (- (: len) (header_len This)))

(dm parse ("LENGTH" "APP")
  (super "LENGTH" "APP")
  (rd (- (header_len This) (len This)))
  (let (rem (data_len This))
    (when "APP"
      (=: next> (new "APP"))
      (setq rem (parse (: next>) rem "APP")))
    (rd rem)
    (- "LENGTH" (: len))
    ))

###############################################################################
# IP Layer
###############################################################################

(class +IPv4 +Layer)

(dm schema ()
  '((flags  2)
    (len    2)
    (ident  2 `(printer~to_hex))
    (frag   2 `(printer~to_hex))
    (ttl    1)
    (proto  1 `(printer~to_hex))
    (chksum 2 `(printer~to_hex))
    (src    4 netutils~ipv4)
    (dst    4 netutils~ipv4)
    ))

(assert-size '+IPv4 20)

(dm ihl ()
  (& (>> 8 (: flags)) 15))

(dm header_len ()
  (>> -2 (ihl This)))

(dm data_len ()
  (- (: len) (header_len This)))

(dm ipv ()
  (>> 4 (& (>> 8 (: flags)) 240)))

(dm get_content_type ()
  (case (: proto)
    (6  '(+TCP))
    (17 '(+UDP))
    (T  NIL)
    ))

(dm parse ("LENGTH" "APP")
  (super "LENGTH" "APP")
  (rd (- (header_len This) (len This)))
  (let (rem     (data_len This)
        content (get_content_type This))
    (when content
      (=: next> (new content))
      (setq rem (parse (: next>) rem "APP")))
    (rd rem)
    (- "LENGTH" (: len))
    ))

###############################################################################
# VLAN layer
###############################################################################

(class +VLAN +Layer)

(dm schema ()
  '((tci  2 `(printer~to_hex))
    (typ  2 `(printer~to_hex))
    ))

(assert-size '+VLAN 4)

(dm get_content_type ()
  (case (pad 4 (hex (: typ)))
    ("0800" '(+IPv4))
    ("8100" '(+VLAN))
    (T      NIL)
    ))

(dm parse ("LENGTH" "APP")
  (let (rem     (super "LENGTH" "APP")
        content (get_content_type This))
    (when content
      (=: next> (new content))
      (setq rem (parse (: next>) rem "APP")))
    rem
    ))

###############################################################################
# Ethernet layer
###############################################################################

(class +Ethernet +Layer)

(dm schema ()
  '((dst  6 netutils~mac)
    (src  6 netutils~mac)
    (typ  2 `(printer~to_hex))
    ))

(assert-size '+Ethernet 14)

(dm get_content_type ()
  (case (pad 4 (hex (: typ)))
    ("0800" '(+IPv4))
    ("8100" '(+VLAN))
    (T    NIL)
    ))

(dm parse ("LENGTH" "APP")
  (let (rem     (super "LENGTH" "APP")
        content (get_content_type This))
    (when content
      (=: next> (new content))
      (setq rem (parse (: next>) rem "APP")))
    rem
    ))

###############################################################################
# Generic inspectors
###############################################################################

(de packet-foldl ("FUN" "LENGTH" "APP" "ACC")
  (let (layer (new '(+Ethernet))
        rem   (parse layer "LENGTH" "APP"))
    (rd rem)
    (foldl layer "FUN" "ACC")
    ))

(de packet-foldr ("FUN" "LENGTH" "APP" "ACC")
  (let (layer (new '(+Ethernet))
        rem   (parse layer "LENGTH" "APP"))
    (rd rem)
    (foldr layer "FUN" "ACC")
    ))

