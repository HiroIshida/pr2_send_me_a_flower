
(defun solve-ik (robot-pre pos rpy which-arm
                            &key
                            (rotation-axis t)
                            )
  (let ((robot-new (copy-object robot-pre)))
    (send robot-new :inverse-kinematics (make-coords :pos pos :rpy rpy)
          :link-list (send robot-new :link-list (send robot-new which-arm :end-coords :parent))
          :move-target (send robot-new which-arm :end-coords)
          :rotation-axis rotation-axis)
    robot-new))

;with side effect 
(defun solve-ik! (robot pos rpy which-arm
                            &key
                            (rotation-axis t)
                            )
  (send robot :inverse-kinematics (make-coords :pos pos :rpy rpy)
        :link-list (send robot :link-list (send robot which-arm :end-coords :parent))
        :move-target (send robot which-arm :end-coords)
        :rotation-axis rotation-axis)


(defun show (robot)
  (objects (list robot)))

(defun transmit-posture (robot &optional (force? nil))
  (if force?
      (send *ri* :angle-vector (send robot :angle-vector) 5000)
      (send *ri* :angle-vector-motion-plan (send robot :angle-vector))
      )
  (send *ri* :wait-interpolation)
  )

(defun follow-robot-sequence (robot-sequence ;; robot-sequence is a list of *robot*
                               &optional (force? nil))
  (let (
        (robot-now (car robot-sequence))
        (robot-seq-remaining (cdr robot-sequence))
        )
    (if (null robot-now)
        (print "finish sequence")
        (progn 
          (transmit-posture robot-now force?)
          (follow-robot-sequence robot-seq-remaining force?)))))

(defun get-msg (name-topic type-topic)
  (let (msg)
    (print "waiting ...")
    (setq msg (one-shot-subscribe name-topic type-topic :after-stamp (ros::time) :timeout 1000000))
    (print "received message")
    msg
    ))




