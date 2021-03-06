#!/usr/bin/env pil

(load "lib/serializable.l")
(load "lib/netstack.l")
(load "lib/pcap.l")
(load "lib/plugin.l")

# Helper functions

(de pcap-scanner (@op @app ghdr phdr)
  (curry (@op @app) (ghdr phdr)
    (prinl "/------------------------[ HDR ]")
    (pcap~display phdr)
    (prinl "\\------------------------[ HDR ]")
    (prinl "/------------------------[ SOP ]")
    (netstack~packet-foldl @op (pcap~len phdr) '@app NIL)
    (prinl "\\------------------------[ EOP ]")))

(de netstack-inspector ("ACC" "LAYER")
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
    (setq *protocol* (plugin~pull proto))
    ))

(load T)

(if *pcapfile*
  (pcap~foreach *pcapfile* (pcap-scanner 'netstack-inspector *protocol*))
  (prinl "USAGE: print.l -pcapfile FILE.pcap -protocol PROTO"))

# Quit

(bye)
