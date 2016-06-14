#
# Note: please load lib/serializable.l in the top level first !
#
(symbols 'pcap 'serializable)

# Global header definition

(class +GlobalHeader +Serializable)

(dm T ()
  (=: magic     0)
  (=: major     0)
  (=: minor     0)
  (=: thiszone  0)   # GMT to local correction
  (=: sigfigs   0)   # Accuracy of timestamps
  (=: snaplen   0)   # Max length of captured packets, in octets
  (=: network   0))  # Data link type

(dm schema ()
  '((-4 magic     printer~to_hex)
    (-2 major     printer~to_hex)
    (-2 minor     printer~to_hex)
    (-4 thiszone  printer~to_hex)
    (-4 sigfigs   printer~to_hex)
    (-4 snaplen   printer~to_hex)
    (-4 network   printer~to_hex)))

(dm nanores? ()
  (= (hex "0XA1B23C4D" (: _magic))))

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
  '((-4 ts_sec  )
    (-4 ts_nsec )
    (-4 incl_len)
    (-4 orig_len)))

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
