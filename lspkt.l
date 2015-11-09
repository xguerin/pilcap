#!/usr/local/bin/picolisp /usr/local/lib/picolisp/lib.l

(load "lib/pcap.l")
(load "lib/netstack.l")

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

(pcap~foreach "data.pcap" (scanner 'dump))

(bye)
