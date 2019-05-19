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

(defun vector-waypoint (v-start v-end n-waypoint)
  (let* ((v-diff (v- v-end v-start))
         (v-diff-each (scale (/ 1.0 n-waypoint) v-diff)))
    (let ((result '()))
      (dotimes (i (+ n-waypoint 1) result)
        (setq result (cons 
                       (v- v-end (scale (* 1.0 i) v-diff-each))
                       result))))))


(defun get-slidearm-robot-sequence (robot-now vec-slide which-arm
                                               &optional 
                                               (n-split 5))
  (let* ((coords-endeffector (send robot-now which-arm :end-coords))
         (rot-endeffector (send coords-endeffector :worldrot))
         (rpy-endeffector-tmp (car (rpy-angle rot-endeffector)))
         (rpy-endeffector (float-vector 
                            (elt rpy-endeffector-tmp 0)
                            (elt rpy-endeffector-tmp 1)
                            (elt rpy-endeffector-tmp 2)))
         (pos-endeffector (send coords-endeffector :worldpos))
         (pos-endeffector-seq (vector-waypoint pos-endeffector (v+ pos-endeffector vec-slide) n-split))
         (av-seq (transform pos-endeffector-seq
                            #'(lambda (pos) (solve-ik robot-now pos rpy-endeffector which-arm
                                                      :rotation-axis t))))
         )
    av-seq))

(setq rs (get-slidearm-robot-sequence *robot* #f(300 0 0) :larm 2))
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

