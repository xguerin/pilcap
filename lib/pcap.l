#
# Note: please load lib/serializable.l in the top level first !
#
(symbols 'pcap 'serializable)

# Global header definition

(class +GlobalHeader +Serializable)

(dm T ()
  (=: magic     "A1B23C4D")
  (=: major     2)
  (=: minor     4)
  (=: thiszone  0)      # GMT to local correction
  (=: sigfigs   0)      # Accuracy of timestamps
  (=: snaplen   65535)  # Max length of captured packets, in octets
  (=: network   1))     # Data link type, default ethernet (1)

(dm schema ()
  '((magic    -4  hex hex)
    (major    -2)
    (minor    -2)
    (thiszone -4)
    (sigfigs  -4)
    (snaplen  -4)
    (network  -4)
    ))

(dm nanores? ()
  (= "A1B23C4D" (: _magic)))

(dm valid? ()
  (and
    (or (= (: magic) "A1B2C3D4")
      (= (: magic) "A1B23C4D"))
    (and (: snaplen)
      (and (: sigfigs)
        (and (: thiszone)
          (and (: minor)
            (and (: magic) (: major))))))))

# Packet header definition

(class +PacketHeader +Serializable)

(dm T ("NS" "TS" "ILEN" "OLEN")
  (default
    "TS"    0
    "OLEN" "ILEN")
  (let (s   (/ "TS" 1000000000)
        ns  (- "TS" (* s 1000000000))
        us  (/ nsec 1000)
        v   (if "NS" ns us))
    (=: ts_sec   s)       # timestamp seconds
    (=: ts_nsec  v)       # timestamp microseconds
    (=: incl_len "ILEN")  # number of octets of packet saved in file
    (=: orig_len "OLEN")  # actual length of packet
    ))

(dm schema ()
  '((ts_sec   -4)
    (ts_nsec  -4)
    (incl_len -4)
    (orig_len -4)
    ))

(dm len ()
  (: incl_len))

(dm timestamp ("NS")
  (if "NS"
    (+ (* (: ts_sec) 1000000000) (: ts_nsec))
    (+ (* (: ts_sec) 1000000000) (* (: ts_nsec) 1000))
    ))

(dm valid? ()
  (and (and (and (: ts_nsec) (: ts_nsec)) (: incl_len)) (: orig_len)))

# Scanner

(de ffw ("LEN")
  (let (_ (rd "LEN")) "LEN"))

(de foreach ("FILE" "CB" "ACC")
  (in "FILE"
    (let (GHDR  (new '(+GlobalHeader))
          PHDR  (new '(+PacketHeader))
          cont  NIL
          acc   "ACC")
      (parse GHDR)
      (display GHDR)
      (when (valid? GHDR)
        (parse PHDR)
        (setq cont (valid? PHDR))
        (while cont
          (setq
            acc   ("CB" GHDR PHDR acc)
            PHDR  (new '(+PacketHeader)))
          (parse PHDR)
          (setq cont (valid? PHDR))
          ))
      acc)))
