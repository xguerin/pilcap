#
# Note: please load lib/serializable.l in the top level first !
#
(symbols 'netstack 'serializable)

(load "lib/netutils.l")

###############################################################################
# Layer class
###############################################################################

(class +Layer +Serializable)

(dm ident ()
  (pack (cdr (chop (name (car (type This)))))))

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
  '((2  src)
    (2  dst)
    (4  seqnum)
    (4  acknum)
    (2  flags   `(printer~to_hex))
    (2  winsize)
    (2  chksum  `(printer~to_hex))
    (2  urgptr  `(printer~to_hex))))

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
  '((2  src)
    (2  dst)
    (2  len)
    (2  chksum `(printer~to_hex))))

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
  '((2  flags)
    (2  len)
    (2  ident   `(printer~to_hex))
    (2  frag    `(printer~to_hex))
    (1  ttl)
    (1  proto   `(printer~to_hex))
    (2  chksum  `(printer~to_hex))
    (4  src)
    (4  dst)))

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
  '((2  tci `(printer~to_hex))
    (2  typ `(printer~to_hex))))

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
  '((6  dst)
    (6  src)
    (2  typ `(printer~to_hex))))

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

