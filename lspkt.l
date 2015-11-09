#!/usr/local/bin/picolisp /usr/local/lib/picolisp/lib.l

(load "lib/pcap.l")
(load "lib/netstack.l")

# Global variables

(setq *pcapfile* NIL)
(de pcapfile () (setq *pcapfile* (name (opt))))

# Helper functions

(de dump (layer)
  (prinl "[---- " (netstack~ident layer) " ----]")
  (netstack~dump layer)
  0)

(de scanner (@op ghdr phdr)
  (curry (@op) (ghdr phdr)
    (prog
      (prinl "/---- SOP ----\\")
      (pcap~dump phdr)
      (pcap~ffw (- (pcap~len phdr) (netstack~inspect @op)))
      (prinl "\\---- EOP ----/"))))

# Main

(load T)

(if *pcapfile*
  (pcap~foreach *pcapfile* (scanner 'dump))
  (prinl "ERROR: -pcapfile must be set"))

# Quit

(bye)
