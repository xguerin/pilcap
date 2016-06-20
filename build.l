#!/usr/bin/env pil

(load "@lib/json.l")
(load "lib/serializable.l")
(load "lib/netstack.l")
(load "lib/pcap.l")
(load "lib/lang.l")

################################################################################
# Helper functions
################################################################################

(de _inspector ("ACC" "LAYER")
  (prinl "|------------------------[ " (netstack~ident "LAYER") " ]")
  (netstack~display "LAYER")
  "ACC")

(de build ("VALMAP" "OUTPUT" "VERBOSE")
  (let (builder '((elt)
                  (let (ts    (car (str (car elt)))
                        obj   (cdr elt)
                        layer (new '(netstack~+Ethernet))
                        len   (netstack~build layer obj)
                        phdr  (new '(pcap~+PacketHeader) T ts len))
                    (when "VERBOSE"
                      (netstack~foldl layer _inspector NIL))
                    (out (pack "+" "OUTPUT")
                      (pcap~dump phdr)
                      (netstack~dump layer)
                      ))))
    (lang~dolist builder "VALMAP")
    ))

################################################################################
# Global variables
################################################################################

(def '*pcapfile*  NIL)
(def '*protocol*  NIL)
(def '*output*    NIL)
(def '*verbose*   NIL)

################################################################################
# Main
################################################################################

(de template ()
  (setq *template* (name (opt))))

(de output ()
  (setq *output* (name (opt))))

(de verbose ()
  (setq *verbose* T))

(load T)

(if (and *template* *output*)
  (in *template*
    (let (json (readJson))
      (if (lst? json)
        (let (ghdr (new '(pcap~+GlobalHeader)))
          (out *output* (pcap~dump ghdr))
            (build json *output* *verbose*))
          (quit (pack "Invalid JSON file: " *template*))
          )))
  (prinl "USAGE: build.l -template TEMPLATE.json -output OUTPUT.pcap"))

################################################################################
# Quit
################################################################################

(bye)
