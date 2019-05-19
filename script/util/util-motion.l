
(defun stop-grasp ()
  (send *ri* :stop-grasp))

(defun start-grasp()
  (send *ri* :start-grasp))

(defun transform (lst fn &optional (result '()));;similar to std::transform of c++
  (let ((top (car lst)) (bottom (cdr lst)))
    (if (null top)
        (reverse result)
        (transform 
          bottom
          fn
          (cons (funcall fn top) result)))))

(defun cut-list-from-start (lst s)
  (if (= s 0)
      lst
      (cut-list-from-start (cdr lst) (- s 1))))

(defun get-vector-waypoint (v-start v-end n-waypoint)
  (let* ((v-diff (v- v-end v-start))
         (v-diff-each (scale (/ 1.0 n-waypoint) v-diff)))
    (let ((result '()))
      (dotimes (i (+ n-waypoint 1) result)
        (setq result (cons 
                       (v- v-end (scale (* 1.0 i) v-diff-each))
                       result))))))

(defun get-end-effector-state (robot which-arm)
  (let* ((coords-endeffector (send robot which-arm :end-coords))
         (rot-endeffector (send coords-endeffector :worldrot))
         (rpy-endeffector-tmp (car (rpy-angle rot-endeffector)))
         (rpy-endeffector (float-vector 
                            (elt rpy-endeffector-tmp 0)
                            (elt rpy-endeffector-tmp 1)
                            (elt rpy-endeffector-tmp 2)))
         (pos-endeffector (send coords-endeffector :worldpos)))
    (list pos-endeffector rpy-endeffector)))



(defun get-slidearm-robot-sequence (robot-now &key 
                                              (r-vec-slide #f(0 0 0))
                                              (l-vec-slide #f(0 0 0))
                                              (n-split 5))
  (let* (
         (r-endeffector-state (get-end-effector-state robot-now :rarm))
         (rpos (car r-endeffector-state))
         (rrpy (car (cdr r-endeffector-state)))
         (rpos-seq (get-vector-waypoint rpos (v+ rpos r-vec-slide) n-split))

         (l-endeffector-state (get-end-effector-state robot-now :larm))
         (lpos (car l-endeffector-state))
         (lrpy (car (cdr l-endeffector-state)))
         (lpos-seq (get-vector-waypoint lpos (v+ lpos l-vec-slide) n-split))
         )
    (let ((result nil))
      (dotimes (i (length lpos-seq) result)
        (let ((robot-tmp (copy-object robot-now)))
          (print (elt rpos-seq i))
          (solve-ik! robot-tmp (elt rpos-seq i) rrpy :rarm :rotation-axis t)
          (solve-ik! robot-tmp (elt lpos-seq i) lrpy :larm :rotation-axis t)
          (show robot-tmp)
          (print (car (get-end-effector-state robot-tmp :larm)))
          (setq result (cons robot-tmp result))))
        (cut-list-from-start (reverse result) 1)
  )))


(setq rs (get-slidearm-robot-sequence *robot* 
                                      :r-vec-slide #f(100 0 0)
                                      :l-vec-slide #f(-300 0 0)
                                      :n-split 3))

(dolist (r rs)
  (progn
    (print "aaaa")
    (setq *robot* r)
    (transmit-posture r t)))






;(setq a (get-slide-arm-robot-sequence *robot* #f(-10 0 0) :larm))















          



      



       

;    (send *ri* :angle-vector-sequence
;	  (list (float-vector 50 5 74 100 -90 -70 -6 20 -70 50 -59 -43 118 0 0 -2 31)
;		(float-vector 50 5 74 100 -90 -70 -6 20 -0 60 -20 -90 118 -90 0 -2 31)
;		(float-vector 50 5 74 100 -90 -70 -6 20 -7 45 -34 -110 12 -38 74 -2 31)
;		(float-vector 50 5 74 100 -90 -70 -6 20 -45 26 -31 -62 22 -76 121 -2 31)
;		(float-vector 150 5 74 100 -90 -70 -6 20 -7 45 -34 -110 12 -38 74 -2 31))
;	  (list 1500 1000 1000 3000 3000))

