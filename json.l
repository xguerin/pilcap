#!/usr/bin/env pil

(load "@lib/json.l")
(load "lib/serializable.l")
(load "lib/pcap.l")
(load "lib/netstack.l")
(load "lib/string.l")
(load "lib/lang.l")

# Helper functions

(de pcap-scanner (@op @app ghdr phdr)
  (curry (@op @app) (ghdr phdr)
    (let (res (netstack~packet-foldr @op (pcap~len phdr) '@app NIL))
      (printJson res)
      )))

(de netstack-inspector ("LAYER" "ACC")
  (let (nam (string~lower (netstack~ident "LAYER"))
        sub (netstack~expand "LAYER")
        cns (cons nam sub)
        cln '((acc elt)
              (cons (cdar elt) acc))
        nac (if (and "ACC" (not (str? (caar "ACC"))))
              (list (cons "entries" (cons T (lang~foldl cln NIL "ACC"))))
              "ACC"))
    (list (if "ACC" (conc cns nac) cns))
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
    (setq *protocol* ((car (str (pack proto "~entrypoint")))))
    ))

(load T)

(if *pcapfile*
  (pcap~foreach *pcapfile* (pcap-scanner 'netstack-inspector *protocol*))
  (prinl "USAGE: json.l -pcapfile FILE.pcap -protocol PROTO"))

# Quit

(bye)
