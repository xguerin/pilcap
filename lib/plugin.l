(symbols 'plugin 'pico)

(load "lib/string.l")

(setq *plugins* NIL)

(de pull ("PLUGNAME")
  (let (pnam  (string~lower "PLUGNAME")
        pent  (assoc pnam *plugins*))
    (if (not pent)
      (prog
        (load (pack "protocol/" pnam ".l"))
        (let (pref ((car (str (pack pnam "~entrypoint")))))
          (setq *plugins* (cons (cons pnam pref) *plugins*))
          pref
        ))
      (list (cadr pent))
      )))

(de available ()
  (mapcar
    '((fn) (string~upper (car ((string~splt ".") fn))))
    (dir "protocol/")
    ))
