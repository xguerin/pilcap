#!/usr/local/bin/picolisp /usr/local/lib/picolisp/lib.l

(load "@lib/misc.l")
(load "lib/pcap.l")
(load "lib/netstack.l")

# Global variables

(setq *pcapfile* NIL)

# Helper functions

(de pcap-scanner (@op ghdr phdr)
  (curry (@op) (ghdr phdr)
    (prog
      (pcap~dump phdr)
      (prinl "/---[ " (align -10 "SOP") " ]")
      (pcap~ffw (- (pcap~len phdr) (netstack~inspect @op)))
      (prinl "\\---[ " (align -10 "EOP") " ]"))))

(de netstack-inspector (layer)
  (prinl "|---[ " (align -10 (netstack~ident layer)) " ]")
  (netstack~dump layer)
  0)

# Main

(setq *pcapfile* (name (opt)))
(load T)

(if *pcapfile*
  (pcap~foreach *pcapfile* (pcap-scanner 'netstack-inspector))
  (prinl "USAGE: lspkt.l FILE.pcap"))

# Quit

(bye)
