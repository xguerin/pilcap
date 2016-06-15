#
# Note: please load lib/serializable.l in the top level first !
#
(symbols 'pcap 'serializable)

# Global header definition

(class +GlobalHeader +Serializable)

(dm T ()
  (=: magic     (hex "A1B23C4D"))
  (=: major     2)
  (=: minor     4)
  (=: thiszone  0)      # GMT to local correction
  (=: sigfigs   0)      # Accuracy of timestamps
  (=: snaplen   65535)  # Max length of captured packets, in octets
  (=: network   1))     # Data link type, default ethernet (1)

(dm schema ()
  '((magic    -4  printer~to_hex)
    (major    -2  printer~to_hex)
    (minor    -2  printer~to_hex)
    (thiszone -4  printer~to_hex)
    (sigfigs  -4  printer~to_hex)
    (snaplen  -4  printer~to_hex)
    (network  -4  printer~to_hex)
    ))

(dm nanores? ()
  (= (hex "A1B23C4D" (: _magic))))

(dm valid? ()
  (and
    (or (= (hex (: magic)) "A1B2C3D4")
      (= (hex (: magic)) "A1B23C4D"))
    (and (: snaplen)
      (and (: sigfigs)
        (and (: thiszone)
          (and (: minor)
            (and (: magic) (: major))))))))

# Packet header definition

(class +PacketHeader +Serializable)

(dm T ()
  (=: ts_sec   0)   # timestamp seconds
  (=: ts_nsec  0)   # timestamp microseconds
  (=: incl_len 0)   # number of octets of packet saved in file
  (=: orig_len 0))  # actual length of packet

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
