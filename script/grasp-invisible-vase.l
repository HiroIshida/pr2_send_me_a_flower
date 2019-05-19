(load "package://pr2eus/pr2-interface.l")
(ros::load-ros-manifest "jsk_recognition_msgs")
(ros::load-ros-manifest "roseus")
(ros::load-ros-manifest "pr2_send_flower")

(pr2-init)
(load "util-motion.l")
(load "util-ros.l")
(load "ishida-pr2-init.l")
(unix:sleep 10)
;(speak-en "start")

(ros::roseus "trigger_test" :anonymous t)
(ros::wait-for-service "trigger")
(setq req (instance pr2_send_flower::ReachPointRequest :init))
(setq res (ros::service-call "trigger" req))
(print "a")
(setq pos-flower 
      (let* (
             (pos-srv (send res :position))
             (pos-vec (float-vector 
                        (* (send pos-srv :x) 1000)
                        (* (send pos-srv :y) 1000)
                        (+ (* (send pos-srv :z) 1000) 60)
                        ))
             )
        pos-vec
        ))

(setq pos-rarm (v+ pos-flower #f(0 -150 30)))
(setq pos-larm (v+ pos-flower #f(0 150 30)))
(solve-ik! *robot* pos-rarm #f(1.57 1.57 0) :rarm :rotation-axis t)
(solve-ik! *robot* pos-larm #f(1.57 1.57 0) :larm :rotation-axis t)
(show *robot*)
(transmit-posture *robot*)

; sandwitch 
(transmit-robot-sequence *robot* 
                         (get-slidearm-robot-sequence
                           *robot* :r-vec-slide #f(0 110 0) :l-vec-slide #f(0 -110 0) :n-split 4)
                         :duration 1000)

; leave for once
(setq pos-rarm (v+ pos-rarm #f(0 -80 0)))
(solve-ik! *robot* pos-rarm #f(1.57 1.57 0) :rarm :rotation-axis t)
(show *robot*)
(transmit-posture *robot*)

; attack pose
(solve-ik! *robot* pos-rarm #f(1.57 0.3 0) :rarm :rotation-axis t)
(show *robot*)
(transmit-posture *robot*)
(send *ri* :stop-grasp :rarm)

; attack
(setq pos-rarm (v+ pos-rarm #f(0 200 0)))
(solve-ik! *robot* pos-rarm #f(1.57 0.3 0) :rarm :rotation-axis t)
(show *robot*)
(transmit-posture *robot*)

; grasp
(send *ri* :start-grasp :rarm)

(setq pos-rarm (v+ pos-rarm #f(0 0 100)))
(solve-ik! *robot* pos-rarm #f(1.57 0.3 0) :rarm :rotation-axis t)
(show *robot*)
(transmit-posture *robot*)



