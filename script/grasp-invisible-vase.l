(load "package://pr2eus/pr2-interface.l")
(load "util.l")
(ros::load-ros-manifest "jsk_recognition_msgs")
(ros::load-ros-manifest "roseus")
(ros::load-ros-manifest "pr2_send_flower")
(print "a")

(pr2-init)
(load "ishida-pr2-init.l")
(setq *robot* *pr2*)
(setq *r* *robot*)

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

(defun tp () (transmit-posture *robot* t))

(setq pos-rarm (v+ pos-flower #f(0 -150 30)))
(setq pos-larm (v+ pos-flower #f(0 150 30)))
(solve-ik! *robot* pos-rarm #f(1.57 1.57 0) :rotation-axis t :which-arm :rarm)
(solve-ik! *robot* pos-larm #f(1.57 1.57 0) :rotation-axis t :which-arm :larm)
(show *robot*)
(transmit-posture *robot* t)

(setq pos-rarm (v+ pos-rarm #f(0 30 0)))
(setq pos-larm (v+ pos-larm #f(0 -30 0)))
(solve-ik! *robot* pos-rarm #f(1.57 1.57 0) :rotation-axis t :which-arm :rarm)
(solve-ik! *robot* pos-larm #f(1.57 1.57 0) :rotation-axis t :which-arm :larm)
(show *robot*)
(transmit-posture *robot* t)

(setq pos-rarm (v+ pos-rarm #f(0 30 0)))
(setq pos-larm (v+ pos-larm #f(0 -30 0)))
(solve-ik! *robot* pos-rarm #f(1.57 1.57 0) :rotation-axis t :which-arm :rarm)
(solve-ik! *robot* pos-larm #f(1.57 1.57 0) :rotation-axis t :which-arm :larm)
(show *robot*)
(transmit-posture *robot* t)

(setq pos-rarm (v+ pos-rarm #f(0 30 0)))
(setq pos-larm (v+ pos-larm #f(0 -30 0)))
(solve-ik! *robot* pos-rarm #f(1.57 1.57 0) :rotation-axis t :which-arm :rarm)
(solve-ik! *robot* pos-larm #f(1.57 1.57 0) :rotation-axis t :which-arm :larm)
(show *robot*)
(transmit-posture *robot* t)

(setq pos-rarm (v+ pos-rarm #f(0 20 0)))
(setq pos-larm (v+ pos-larm #f(0 -20 0)))
(solve-ik! *robot* pos-rarm #f(1.57 1.57 0) :rotation-axis t :which-arm :rarm)
(solve-ik! *robot* pos-larm #f(1.57 1.57 0) :rotation-axis t :which-arm :larm)
(show *robot*)
(transmit-posture *robot* t)

(setq pos-rarm (v+ pos-rarm #f(0 -80 0)))
(solve-ik! *robot* pos-rarm #f(1.57 1.57 0) :rotation-axis t :which-arm :rarm)
(show *robot*)
(transmit-posture *robot* t)




