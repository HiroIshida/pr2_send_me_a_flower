(defun list-ref (lst n)
  (let ((top (car lst))(bottom (cdr lst)))
    (if (= n 0)
        top
        (list-ref bottom (- n 1)))))

