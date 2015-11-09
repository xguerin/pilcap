#!/usr/local/bin/picolisp /usr/local/lib/picolisp/lib.l

(load "lib/pcap.l")
(load "lib/netstack.l")

# Global variables

(setq *pcapfile* NIL)
(de pcapfile () (setq *pcapfile* (name (opt))))

# Helper functions

(de pcap-scanner (@op ghdr phdr)
  (curry (@op) (ghdr phdr)
    (prog
      (prinl "/---- SOP ----\\")
      (pcap~dump phdr)
      (pcap~ffw (- (pcap~len phdr) (netstack~inspect @op)))
      (prinl "\\---- EOP ----/"))))

(de netstack-inspector (layer)
  (prinl "[---- " (netstack~ident layer) " ----]")
  (netstack~dump layer)
  0)

# Main

(load T)

(if *pcapfile*
  (pcap~foreach *pcapfile* (pcap-scanner 'netstack-inspector))
  (prinl "ERROR: -pcapfile must be set"))

# Quit

(bye)
