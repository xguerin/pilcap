#!/usr/bin/env pil

(load "@lib/json.l")
(load "lib/serializable.l")
(load "lib/pcap.l")
(load "lib/netstack.l")

# Helper functions

# Global variables

(setq *pcapfile*  NIL)
(setq *protocol*  NIL)
(setq *output*    NIL)

# Main

(de template ()
  (setq *template* (name (opt))))

(de output ()
  (setq *output* (name (opt))))

(load T)

(if (and *template* *output*)
  (in *template*
    (let (json (readJson))
      (if (lst? json)
        (pcap~build (new '(pcap~+GlobalHeader)) json)
        (quit (pack "Invalid JSON file: " *template*))
        )))
  (prinl "USAGE: build.l -template TEMPLATE.json -output OUTPUT.pcap"))

# Quit

(bye)
