(symbols 'pcap 'pico)

(load "@lib/misc.l")

# Global header definition

(class +GlobalHeader)

(dm T ()
	(=: _magic 		(rd -4))
	(=: _major 		(rd -2))
	(=: _minor 		(rd -2))
	(=: _thiszone	(rd -4)) # GMT to local correction
	(=: _sigfigs  (rd -4)) # Accuracy of timestamps
	(=: _snaplen	(rd -4)) # Max length of captured packets, in octets
	(=: _network	(rd -4)) # Data link type
)

(dm nanores? ()
  (= (hex "0XA1B23C4D" (: _magic))))

(dm valid? ()
  (and
    (or (= (hex (: _magic)) "A1B2C3D4")
      (= (hex (: _magic)) "A1B23C4D"))
  (and (: _snaplen)
    (and (: _sigfigs)
      (and (: _thiszone)
        (and (: _minor)
          (and (: _magic) (: _major))))))))

(dm dump ()
  (prinl "magic   : 0x" (hex (: _magic)))
  (prinl "major   : "   (: _major))
  (prinl "minor   : "   (: _minor))
  (prinl "zone    : "   (: _thiszone))
  (prinl "sigfigs : "   (: _sigfigs))
  (prinl "snaplen	: "   (: _snaplen))
  (prinl "network	: "   (: _network))
)

# Packet header definition

(class +PacketHeader)

(dm T ()
  (=: _ts_sec   (rd -4)) # timestamp seconds
  (=: _ts_nsec  (rd -4)) # timestamp microseconds
  (=: _incl_len (rd -4)) # number of octets of packet saved in file
  (=: _orig_len (rd -4)) # actual length of packet
)

(dm len ()
  (: _incl_len))

(dm timestamp ("NS")
  (if "NS"
    (+ (* (: _ts_sec) 1000000000) (: _ts_nsec))
    (+ (* (: _ts_sec) 1000000000) (* (: _ts_nsec) 1000))
    ))

(dm valid? ()
  (and (and (and (: _ts_nsec) (: _ts_nsec)) (: _incl_len)) (: _orig_len)))

(dm dump ()
  (prinl "seconds       : "   (: _ts_sec))
  (prinl "nanoseconds   : "   (: _ts_nsec))
  (prinl "included len  : "   (: _incl_len))
  (prinl "original len  : "   (: _orig_len))
)

# Scanner

(de ffw ("LEN")
  (let (_ (rd "LEN")) "LEN"))

(de foreach ("FILE" "CB" "ACC")
  (in "FILE"
    (let (GHDR  (new '(+GlobalHeader))
          PHDR  (new '(+PacketHeader))
          cont  (valid? GHDR)
          acc   "ACC")
      (when (valid? GHDR)
        (while cont
          (setq
            acc   ("CB" GHDR PHDR acc)
            PHDR  (new '(+PacketHeader))
            cont  (valid? PHDR))))
      acc)))
