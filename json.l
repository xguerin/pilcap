#!/usr/local/bin/picolisp /usr/local/lib/picolisp/lib.l

(load "@lib/misc.l")
(load "@lib/json.l")
(load "lib/pcap.l")
(load "lib/netstack.l")
(load "lib/string.l")

# Helper functions

(de pcap-scanner (@op @app ghdr phdr)
  (curry (@op @app) (ghdr phdr)
    (let (res (netstack~inspect @op '@app '(0, NIL)))
      (printJson (cadr res))
      (pcap~ffw (- (pcap~len phdr) (car res)))
  )))

(de netstack-inspector ("LAYER" "ACC")
  (let (key (string~lower (netstack~ident "LAYER"))
        sub (netstack~expand "LAYER")
        cns (list (cons key sub)))
    (conc "ACC" cns)
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
  (prinl "USAGE: json.l FILE.pcap"))

# Quit

(bye)
