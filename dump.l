#!/apps/infrafs1/xguerin/.local/picolisp/bin/picolisp /apps/infrafs1/xguerin/.local/picolisp/lib.l

(load "@lib/misc.l")
(load "lib/serializable.l")
(load "lib/pcap.l")
(load "lib/netstack.l")

# Helper functions

(setq *doglobalhdr*  T)

(de pcap-scanner (@op @app @output ghdr phdr)
  (curry (@op @app @output) (ghdr phdr)
    (out @output
      (prog
        (when *doglobalhdr*
          (pcap~dump ghdr)
          (setq *doglobalhdr* NIL))
        (pcap~dump phdr)
        (pcap~ffw (- (pcap~len phdr) (car (netstack~packet-foldl @op '@app '(0, NIL)))))
        ))
    ))

(de netstack-inspector ("LAYER" "ACC")
  (netstack~dump "LAYER")
  "ACC")

# Global variables

(setq *pcapfile*  NIL)
(setq *protocol*  NIL)
(setq *output*    NIL)

# Main

(de pcapfile ()
  (setq *pcapfile* (name (opt))))

(de protocol ()
  (let (proto (name (opt)))
    (load (pack "protocol/" proto ".l"))
    (setq *protocol* ((car (str "itch50~entrypoint"))))))

(de output ()
  (setq *output* (name (opt))))

(load T)

(if (and *pcapfile* *output*)
  (pcap~foreach *pcapfile* (pcap-scanner 'netstack-inspector *protocol* *output*))
  (prinl "USAGE: dump.l -pcapfile FILE.pcap -protocol PROTO -output OUTPUT.pcap"))

# Quit

(bye)
