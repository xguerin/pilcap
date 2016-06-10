#!/usr/bin/env pil

(load "lib/serializable.l")
(load "lib/pcap.l")
(load "lib/netstack.l")

# Helper functions

(de pcap-scanner (@op @app ghdr phdr)
  (curry (@op @app) (ghdr phdr)
    (prinl "/------------------------[ HDR ]")
    (pcap~display phdr)
    (prinl "\\------------------------[ HDR ]")
    (prinl "/------------------------[ SOP ]")
    (let ((rem res) (netstack~packet-foldl @op '@app (pcap~len phdr) NIL))
      (pcap~ffw rem)
      (prinl "\\------------------------[ EOP ]"))))

(de netstack-inspector ("LAYER" "ACC")
  (prinl "|------------------------[ " (netstack~ident "LAYER") " ]")
  (netstack~display "LAYER")
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
    (setq *protocol* ((car (str (pack proto "~entrypoint")))))
    ))

(load T)

(if *pcapfile*
  (pcap~foreach *pcapfile* (pcap-scanner 'netstack-inspector *protocol*))
  (prinl "USAGE: print.l -pcapfile FILE.pcap -protocol PROTO"))

# Quit

(bye)
