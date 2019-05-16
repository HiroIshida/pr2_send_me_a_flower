(load "package://pr2eus/pr2-interface.l")
(load "util.l")
(ros::load-ros-manifest "jsk_recognition_msgs")
(ros::load-ros-manifest "roseus")
(ros::load-ros-manifest "pr2_send_flower")
(print "a")

(pr2-init)
(setq *robot* *pr2*)
(setq *r* *robot*)

(ros::roseus "trigger_test" :anonymous t)
(ros::wait-for-service "trigger")
(setq req (instance pr2_send_flower::ReachPointRequest :init))
(setq res (ros::service-call "trigger" req))
(print "a")
(setq pos-reach 
      (let* (
             (pos-srv (send res :position))
             (pos-vec (float-vector 
                        (* (send pos-srv :x) 1000)
                        (* (send pos-srv :y) 1000)
                        (* (send pos-srv :z) 1000)
                        ))
             )
        pos-vec
        ))

(solve-ik! *robot* pos-reach #f(-1.57 0 0) :rotation-axis nil :which-arm :rarm)
;(show *robot*)




;(setq w 50)
;(dotimes (i 5)
;  (send *robot* :rarm :move-end-pos (float-vector (* w 1) 20 0) :world)
;  (transmit-posture t)
;  (send *robot* :rarm :move-end-pos (float-vector (* w -1) 20 0) :world)
;  (transmit-posture t)
;  )
