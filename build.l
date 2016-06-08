#!/usr/bin/env pil

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
  NIL
  (prinl "USAGE: build.l -template TEMPLATE.json -output OUTPUT.pcap"))

# Quit

(bye)
