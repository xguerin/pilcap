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

(dm foldl ("CB" "APP" "ACC")
  (list (- (car "ACC") (len This)) ("CB" This (cadr "ACC"))))

(dm foldr ("CB" "APP" "ACC")
  (list (- (car "ACC") (len This)) ("CB" This (cadr "ACC"))))

###############################################################################
# TCP Layer
###############################################################################

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
        sze (- (car "ACC") (len This))
        nac (list sze nxt) )
    (if "APP"
      (foldl (parse (new "APP")) "CB" "APP" nac)
      nac
      )))

(dm foldr ("CB" "APP" "ACC")
  (let (fut (if "APP"
              (foldr (parse (new "APP")) "CB" "APP" "ACC")
              "ACC")
        nxt ("CB" This (cadr fut))
        sze (- (car fut) (len This)))
    (list sze nxt)))

###############################################################################
# UDP layer
###############################################################################

(class +UDP +Layer)

(dm schema ()
  '((2  src     ""    format)
    (2  dst     ""    format)
    (2  len     ""    format)
    (2  chksum  "0x"  hex)))

(dm header_len () 8)

(dm data_len ()
  (- (: len) (header_len This)))

(dm foldl ("CB" "APP" "ACC")
  (let (res         ("CB" This (cadr "ACC"))
        sze         (- (car "ACC") (len This))
        #
        # Replace the size of the upcoming data with the one specified by IP
        #
        nac         (list (data_len This) res)
        #
        # Then foldl the next data in line
        #
        (rlen rdat) (if "APP" (foldl (parse (new "APP")) "CB" "APP" nac) nac))
    #
    # Compute the remainder of data length and pass it as a result
    #
    (list (- sze (- (data_len This) rlen)) rdat)
    ))

(dm foldr ("CB" "APP" "ACC")
  (let ((ilen idat) "ACC"
        #
        # Replace the size of the upcoming data with the one specified by IP
        #
        nac         (list (data_len This) idat)
        #
        # Then foldr the next data in line
        #
        (rlen rdat) (if "APP" (foldr (parse (new "APP")) "CB" "APP" nac) nac)
        #
        # Call the callback on the result
        #
        res         ("CB" This rdat)
        sze         (- ilen (len This)))
    #
    # Compute the remainder of data length and pass it as a result
    #
    (list (- sze (- (data_len This) rlen)) res)
    ))

###############################################################################
# IP Layer
###############################################################################

(class +IPv4 +Layer)

(dm schema ()
  '((2  flags   "0x"  hex)
    (2  len 	  ""    format)
    (2  ident   "0x"  hex)
    (2  frag	  "0x"  hex)
    (1  ttl 	  "0x"  hex)
    (1  proto   "0x"  hex)
    (2  chksum  "0x"  hex)
    (4  src	    "0x"  hex T)
    (4  dst	    "0x"  hex T)))

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

(dm foldl ("CB" "APP" "ACC")
  (let (res         ("CB" This (cadr "ACC"))
        sze         (- (car "ACC") (len This))
        content     (get_content_type This)
        #
        # Replace the size of the upcoming data with the one specified by IP
        #
        nac         (list (data_len This) res)
        #
        # Then foldl the next data in line
        #
        (rlen rdat) (if content (foldl (parse (new content)) "CB" "APP" nac) nac))
    #
    # Compute the remainder of data length and pass it as a result
    #
    (list (- sze (- (data_len This) rlen)) rdat)
    ))

(dm foldr ("CB" "APP" "ACC")
  (let ((ilen idat) "ACC"
        content     (get_content_type This)
        #
        # Replace the size of the upcoming data with the one specified by IP
        #
        nac         (list (data_len This) idat)
        #
        # Then foldr the next data in line
        #
        (rlen rdat) (if content (foldr (parse (new content)) "CB" "APP" nac) nac)
        #
        # Call the callback on the result
        #
        res         ("CB" This rdat)
        sze         (- ilen (len This)))
    #
    # Compute the remainder of data length and pass it as a result
    #
    (list (- sze (- (data_len This) rlen)) res)
    ))

###############################################################################
# VLAN layer
###############################################################################

(class +VLAN +Layer)

(dm schema ()
  '((2  tci   "0x"  hex)
    (2  type  "0x"  hex)))

(dm get_content_type ()
  (case (pad 4 (hex (: type)))
    ("0800" '(+IPv4))
    ("8100" '(+VLAN))
    (T    NIL)
    ))

(dm foldl ("CB" "APP" "ACC")
  (let (nxt     ("CB" This (cadr "ACC"))
        sze     (- (car "ACC") (len This))
        nac     (list sze nxt)
        content (get_content_type This))
    (if content
      (foldl (parse (new content)) "CB" "APP" nac)
      nac)
      ))

(dm foldr ("CB" "APP" "ACC")
  (let (content (get_content_type This)
        fut     (if content (foldr (parse (new content)) "CB" "APP" "ACC") "ACC")
        nxt     ("CB" This (cadr fut))
        sze     (- (car fut) (len This)))
    (list sze nxt)))

###############################################################################
# Ethernet layer
###############################################################################

(class +Ethernet +Layer)

(dm schema ()
  '((6  dst   "0x"  hex T)
    (6  src   "0x"  hex T)
    (2  type  "0x"  hex)))

(dm get_content_type ()
  (case (pad 4 (hex (: type)))
    ("0800" '(+IPv4))
    ("8100" '(+VLAN))
    (T    NIL)
    ))

(dm foldl ("CB" "APP" "ACC")
  (let (nxt     ("CB" This (cadr "ACC"))
        sze     (- (car "ACC") (len This))
        nac     (list sze nxt)
        content (get_content_type This))
    (if content
      (foldl (parse (new content)) "CB" "APP" nac)
      nac)
      ))

(dm foldr ("CB" "APP" "ACC")
  (let (content (get_content_type This)
        fut     (if content (foldr (parse (new content)) "CB" "APP" "ACC") "ACC")
        nxt     ("CB" This (cadr fut))
        sze     (- (car fut) (len This)))
    (list sze nxt)))

###############################################################################
# Generic inspectors
###############################################################################

(de packet-foldl ("CB" "APP" "LEN" "ACC")
  (let (layer (parse (new '(+Ethernet))))
    (foldl layer "CB" "APP" (list "LEN" "ACC"))))

(de packet-foldr ("CB" "APP" "LEN" "ACC")
  (let (layer (parse (new '(+Ethernet))))
    (foldr layer "CB" "APP" (list "LEN" "ACC"))))

