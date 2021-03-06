#
# Note: please load lib/serializable.l in the top level first !
#
(symbols 'netstack 'serializable)

(load "lib/netutils.l")
(load "lib/plugin.l")

###############################################################################
# Layer class
###############################################################################

(class +Layer +Serializable)

(dm build ("VALMAP")
  (let (srch '((elt)
               (let ((dsc len NIL NIL)  elt
                     mapent             (assoc (name dsc) "VALMAP")
                     (k . v)            mapent)
                 (when mapent
                   (put This dsc v)
                   ))))
    (lang~dolist srch (schema This))
    (len This)
    ))

(dm padding () 0)

(dm dump ()
  (super)
  (lang~nwr (list (padding This) 0))
  (when (: next>)
    (if (lst? (: next>))
      (lang~dolist '((elt) (dump elt)) (: next>))
      (dump (: next>))
      )))

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

(dm T ()
  (=: src     0)
  (=: dst     0)
  (=: seqnum  0)
  (=: acknum  0)
  (=: flags   0)
  (=: winsize 0)
  (=: chksum  0)
  (=: urgptr  0))

(dm schema ()
  '((src      2)
    (dst      2)
    (seqnum   4)
    (acknum   4)
    (flags    2)
    (winsize  2)
    (chksum   2)
    (urgptr   2)
    ))

(assert-size '+TCP 20)

(dm header_len ()
  (len This))

(dm build ("VALMAP")
  (super "VALMAP")
  (for PLUG (plugin~available)
    (T (assoc PLUG "VALMAP")
       (let ((k . v) (assoc PLUG "VALMAP")
             entrypt  (plugin~pull PLUG))
         (=: next> (new entrypt))
         (=: len (+ (build (: next>) v) (len This)))
         (: len)
         )))
  (when (not (: next>))
    (len This)
    ))

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

(dm T ()
  (=: src     0)
  (=: dst     0)
  (=: len     0)
  (=: chksum  0))

(dm schema ()
  '((src    2)
    (dst    2)
    (len    2)
    (chksum 2)
    ))

(assert-size '+UDP 8)

(dm header_len ()
  (len This))

(dm data_len ()
  (- (: len) (header_len This)))

(dm build ("VALMAP")
  (=: len (super "VALMAP"))
  (for PLUG (plugin~available)
    (T (assoc PLUG "VALMAP")
       (let ((k . v) (assoc PLUG "VALMAP")
             entrypt  (plugin~pull PLUG))
         (=: next> (new entrypt))
         (=: len (+ (: len) (build (: next>) v)))
         )))
  (: len))

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

(dm T ()
  (=: flags   "4500")
  (=: len     0)
  (=: ident   "1FFA")
  (=: frag    "4000")
  (=: ttl     24)
  (=: proto   0)
  (=: chksum  0)
  (=: src     "0.0.0.0")
  (=: dst     "0.0.0.0"))

(dm schema ()
  '((flags  2 hex hex)
    (len    2)
    (ident  2 hex hex)
    (frag   2 hex hex)
    (ttl    1)
    (proto  1)
    (chksum 2)
    (src    4 netutils~ipv4 netutils~ipv4)
    (dst    4 netutils~ipv4 netutils~ipv4)
    ))

(assert-size '+IPv4 20)

(dm ihl ()
  (& (>> 8 (hex (: flags))) 15))

(dm header_len ()
  (>> -2 (ihl This)))

(dm data_len ()
  (- (: len) (header_len This)))

(dm ipv ()
  (>> 4 (& (>> 8 (: flags)) 240)))

(dm build ("VALMAP")
  (super "VALMAP")
  (cond
    ((assoc "TCP" "VALMAP")
     (let (tcp (assoc "TCP" "VALMAP"))
       (=: next> (new '(+TCP)))
       (=: proto 6)
       (=: len (+ (build (: next>) tcp) (len This)))
       (: len)
       ))
    ((assoc "UDP" "VALMAP")
     (let (udp (assoc "UDP" "VALMAP"))
       (=: next> (new '(+UDP)))
       (=: proto 17)
       (=: len (+ (build (: next>) udp) (len This)))
       (: len)
       ))
    (T (len This))
    ))

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

(dm T ()
  (=: tci 0)
  (=: typ "0"))

(dm schema ()
  '((tci  2)
    (typ  2 hex `(printer~to_hex 4))
    ))

(assert-size '+VLAN 4)

(dm build ("VALMAP")
  (super "VALMAP")
  (cond
    ((assoc "IPv4" "VALMAP")
     (let (ipv4 (assoc "IPv4" "VALMAP"))
       (=: next> (new '(+IPv4)))
       (=: typ "0800")
       (+ (build (: next>) ipv4) (len This))
       ))
    ((assoc "VLAN" "VALMAP")
     (let (vlan (assoc "VLAN" "VALMAP"))
       (=: next> (new '(+VLAN)))
       (=: typ "8100")
       (+ (build (: next>) vlan) (len This))
       ))
    (T (len This))
    ))

(dm get_content_type ()
  (case (: typ)
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

(dm T ()
  (=: dst "00:00:00:00")
  (=: src "00:00:00:00")
  (=: typ "0"))

(dm schema ()
  '((dst  6 netutils~mac  netutils~mac)
    (src  6 netutils~mac  netutils~mac)
    (typ  2 hex           `(printer~to_hex 4))
    ))

(assert-size '+Ethernet 14)

(dm build ("VALMAP")
  (super "VALMAP")
  (cond
    ((assoc "IPv4" "VALMAP")
     (let (ipv4 (assoc "IPv4" "VALMAP"))
       (=: next> (new '(+IPv4)))
       (=: typ "0800")
       (+ (build (: next>) ipv4) (len This))
       ))
    ((assoc "VLAN" "VALMAP")
     (let (vlan (assoc "VLAN" "VALMAP"))
       (=: next> (new '(+VLAN)))
       (=: typ "8100")
       (+ (build (: next>) vlan) (len This))
       ))
    (T (len This))
    ))

(dm get_content_type ("APP")
  (if (> (hex (: typ)) 1536)
    (case (: typ)
      ("0800" '(+IPv4))
      ("8100" '(+VLAN))
      (T      NIL))
    "APP"
    ))

(dm get_content_len ("LENGTH")
  (if (> (hex (: typ)) 1536)
    "LENGTH"
    (hex (: typ))
    ))

(dm get_content_rem ("LENGTH" "REM")
  (if (> (hex (: typ)) 1536)
    "REM"
    (- "LENGTH" (- (hex (: typ)) "REM"))
    ))

(dm parse ("LENGTH" "APP")
  (let (rem     (super "LENGTH" "APP")
        res     rem
        content (get_content_type This "APP"))
    (when content
      (=: next> (new content))
      (setq res (parse (: next>) (get_content_len This rem) "APP")))
    (get_content_rem This rem res)
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

