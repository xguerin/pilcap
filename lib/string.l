(symbols 'string 'pico)

(de lower ("STR")
  (when (str? "STR")
    (pack (mapcar
            '((c)
              (let (v (char c))
                (if (and (>= v (char "A")) (<= v (char "Z")))
                  (char (+ v 32))
                  c)))
            (chop "STR"))
    )))

(de upper ("STR")
  (when (str? "STR")
    (pack (mapcar
            '((c)
              (let (v (char c))
                (if (and (>= v (char "a")) (<= v (char "z")))
                  (char (- v 32))
                  c)))
            (chop "STR"))
    )))
