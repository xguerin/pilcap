# vim: set ft=picolisp:

(symbols 'lang 'pico)

(de foldl (fun acc lst)
  (if (not lst)
    acc
    (foldl fun (fun acc (car lst)) (cdr lst))))

(de foldr (fun lst acc)
  (if (not lst)
    acc
    (fun (car lst) (foldr fun (cdr lst) acc))))

(de dolist (fun lst)
  (when lst
    (fun (car lst))
    (dolist fun (cdr lst))))

