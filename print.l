#!/usr/local/bin/picolisp /usr/local/lib/picolisp/lib.l

(load "@lib/misc.l")
(load "lib/pcap.l")
(load "lib/netstack.l")

# Helper functions

(de pcap-scanner (@op @app ghdr phdr)
  (curry (@op @app) (ghdr phdr)
    (prog
      (pcap~dump phdr)
      (prinl "/----------------[ SOP ]")
      (pcap~ffw (- (pcap~len phdr) (car (netstack~packet-foldl @op '@app '(0, NIL)))))
      (prinl "\\----------------[ EOP ]"))))

(de netstack-inspector ("LAYER" "ACC")
  (prinl "|----------------[ " (netstack~ident "LAYER") " ]")
  (netstack~dump "LAYER")
  "ACC")

# Global variables

(setq *pcapfile*  NIL)
(setq *protocol*  NIL)

# Main

(de pcapfile ()
  (setq *pcapfile* (name (opt))))

(de protocol ()
  (let (proto (name (opt)))
    (load (pack "protocol/" proto ".l"))
    (setq *protocol* ((car (str "itch50~entrypoint"))))))

(load T)

(if *pcapfile*
    (pcap~foreach *pcapfile* (pcap-scanner 'netstack-inspector *protocol*))
    (prinl "USAGE: print.l FILE.pcap"))

# Quit

(bye)
