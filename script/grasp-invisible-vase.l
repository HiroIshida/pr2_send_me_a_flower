(load "package://pr2eus/pr2-interface.l")
(ros::load-ros-manifest "jsk_recognition_msgs")
(ros::load-ros-manifest "roseus")
(ros::load-ros-manifest "pr2_send_flower")

(pr2-init)
(load "util-motion.l")
(load "util-ros.l")
(load "ishida-pr2-init.l")
(unix:sleep 12)
;(speak-en "start")

(ros::roseus "trigger_test" :anonymous t)
(ros::wait-for-service "trigger")
(setq req (instance pr2_send_flower::ReachPointRequest :init))
(speak-jp "見つかりました")
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
        (print "get pos")
        pos-vec
        ))


(setq pos-rarm (v+ pos-flower #f(0 -120 20)))

; leave for once
(solve-ik! *robot* pos-rarm #f(1.57 1.57 0) :rarm :rotation-axis t)
(show *robot*)
(transmit-posture *robot*)

; attack pose
(solve-ik! *robot* pos-rarm #f(1.57 0.3 0) :rarm :rotation-axis t)
(show *robot*)
(transmit-posture *robot*)
(send *ri* :start-grasp)


(ros::wait-for-service "trigger_change_detector_init")
(setq req (instance std_srvs::EmptyRequest :init))
(ros::service-call "trigger_change_detector_init" req)

(setq *isMoved* nil)
(defun callback_cost (msg_cost)
  (let ((cost (send msg_cost :data)))
    (if (> cost 700)
        (setq *isMoved* t))))

(ros::subscribe "/cost" std_msgs::Int64 #'callback_cost)


(ros::rate 30)                                                                              
(do-until-key                                                                              
  (ros::spin-once)                                                                          
  (when *isMoved*                                                                              
    ;(send *ri* :cancel-angle-vector)                                                        
    (speak-jp "衝突しました")
    (return))
  (setq pos-rarm (v+ pos-rarm #f(0 5 0)))
  (solve-ik! *robot* pos-rarm #f(1.57 0.3 0) :rarm :rotation-axis t)
  (show *robot*)
  (send *ri* :angle-vector (send *robot* :angle-vector) 2000)
  (send *ri* :wait-interpolation)
  ;;(unix::usleep (* 700 1000))
  ;;(send *ri* :wait-interpolation)
)


