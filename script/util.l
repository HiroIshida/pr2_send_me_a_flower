
(defun solve-ik! (robot pos rpy 
                            &key
                            (which-arm :larm)
                            (rotation-axis t)
                            )
  (send robot :inverse-kinematics (make-coords :pos pos :rpy rpy)
        :link-list (send robot :link-list (send robot which-arm :end-coords :parent))
        :move-target (send robot which-arm :end-coords)
        :rotation-axis rotation-axis))

(defun show (robot)
  (objects (list robot)))

(defun transmit-posture (&optional (force? nil))
  (if force?
      (send *ri* :angle-vector (send *robot* :angle-vector) 1000)
      (send *ri* :angle-vector-motion-plan (send *robot* :angle-vector))
      )
  (send *ri* :wait-interpolation)
  )

(defun stop-grasp ()
  (send *ri* :stop-grasp))

(defun start-grasp()
  (send *ri* :start-grasp))


