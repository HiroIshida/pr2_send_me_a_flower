(defun list-ref (lst n)
  (let ((top (car lst))(bottom (cdr lst)))
    (if (= n 0)
        top
        (list-ref bottom (- n 1)))))

(defun square (x) (* x x))

(defun dist (pos1 pos2)
  (let* (
         (x1 (elt pos1 0)) (y1 (elt pos1 1)) (z1 (elt pos1 1))
         (x2 (elt pos2 0)) (y2 (elt pos2 1)) (z2 (elt pos2 1))
         )
    (sqrt (+ 
            (square (- x1 x2))
            (square (- y1 y2))
            (square (- z1 z2))
            ))))

