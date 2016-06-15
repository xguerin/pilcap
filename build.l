#!/usr/bin/env pil

(load "@lib/json.l")
(load "lib/serializable.l")
(load "lib/pcap.l")
(load "lib/netstack.l")
(load "lib/lang.l")

################################################################################
# Helper functions
################################################################################

(de _inspector ("ACC" "LAYER")
  (prinl "|------------------------[ " (netstack~ident "LAYER") " ]")
  (netstack~display "LAYER")
  "ACC")

(de build ("VALMAP")
  (let (builder '((elt)
                  (let (ts    (car elt)
                        obj   (cdr elt)
                        layer (new '(netstack~+Ethernet)))
                    (netstack~build layer obj)
                    (netstack~foldl layer _inspector NIL)
                    (prinl "|------------------------|")
                    )))
    (lang~dolist builder "VALMAP")
    ))

################################################################################
# Global variables
################################################################################

(setq *pcapfile*  NIL)
(setq *protocol*  NIL)
(setq *output*    NIL)

################################################################################
# Main
################################################################################

(de template ()
  (setq *template* (name (opt))))

(de output ()
  (setq *output* (name (opt))))

(load T)

(if (and *template* *output*)
  (in *template*
    (let (json (readJson))
      (if (lst? json)
        (build json)
        (quit (pack "Invalid JSON file: " *template*))
        )))
  (prinl "USAGE: build.l -template TEMPLATE.json -output OUTPUT.pcap"))

################################################################################
# Quit
################################################################################

(bye)
