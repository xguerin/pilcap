#!/usr/bin/env pil

(load "@lib/json.l")
(load "lib/serializable.l")
(load "lib/pcap.l")
(load "lib/netstack.l")
(load "lib/string.l")

# Helper functions

(de pcap-scanner (@op @app ghdr phdr)
  (curry (@op @app) (ghdr phdr)
    (let (acc       (list (pcap~len phdr) NIL)
          (rem res) (netstack~packet-foldr @op '@app acc))
      (printJson res)
      (pcap~ffw rem)
      )))

(de netstack-inspector ("LAYER" "ACC")
  (let (key (string~lower (netstack~ident "LAYER"))
        sub (netstack~expand "LAYER")
        cns (cons key sub))
    (conc "ACC" (list cns))
    ))

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
  (prinl "USAGE: json.l -pcapfile FILE.pcap -protocol PROTO"))

# Quit

(bye)
