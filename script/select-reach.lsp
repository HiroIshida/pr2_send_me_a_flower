#!/usr/bin/env roseus
(require "package://pr2eus/pr2-interface.l")
(require "models/arrow-object.l")

(ros::roseus "reaching")
(ros::load-ros-manifest "jsk_recognition_msgs")
(ros::load-ros-manifest "roseus")
(print "finish loading")

(pr2-init)
(print "robot initialized")
(setq *tfl* (instance ros::transform-listener :init))
(setq *robot* *pr2*)

(defun robot-init! ()
    (send *robot* :reset-manip-pose)
    (send *robot* :l_upper_arm_roll_joint :joint-angle -10)
    (send *robot* :r_upper_arm_roll_joint :joint-angle -10)
    (send *robot* :l_shoulder_lift_joint :joint-angle -20)
    (send *robot* :r_shoulder_lift_joint :joint-angle -20)
    (send *robot* :l_upper_arm_roll_joint :joint-angle 40)
    (send *robot* :r_upper_arm_roll_joint :joint-angle -40)
    (send *robot* :torso_lift_joint :joint-angle 20)
    )

(defun get-box-global-coords (bbox)
  (let* (
         (coords-local (ros::tf-pose->coords (send bbox :pose)))
         (tf-local->global (send *tfl* :lookup-transform "/base_footprint" (send bbox :header :frame_id) (ros::time 0)))
         (print (send bbox :header :frame_id))
         (coords-global (send tf-local->global :transform coords-local))
         )
    coords-global
    ))

(defun solve-ik! (robot pos rpy 
                            &key
                            (which-arm :larm)
                            (rotation-axis nil)
                            )
  (send robot :inverse-kinematics (make-coords :pos pos :rpy rpy)
        :link-list (send robot :link-list (send robot which-arm :end-coords :parent))
        :move-target (send robot which-arm :end-coords)
        :rotation-axis rotation-axis))

(defun compute-pos-boxtop (bbox)
  (let* (
         (pos-box (send (get-box-global-coords bbox) :pos))
         (pos-boxtop (v+ pos-box #f(0 0 0.3)))
         )
    pos-boxtop
    ))

(defun show (robot)
  (objects (list robot)))

(defun transmit-posture ()
  (send *ri* :angle-vector (send *robot* :angle-vector) 5000))

; (ex) name-topic "/vase_detection/boxes"
; (ex) "/vase_detection/bounding_box_marker/selected_box"
(defun get-msg (name-topic type-topic)
  (let (msg)
    (setq msg (one-shot-subscribe name-topic type-topic :after-stamp (ros::time)))
    msg
    ))

;(get-msg "/vase_detection/bounding_box_marker/selected_box"
         ;jsk_recognition_msgs::BoundingBox)

;(setq msg-box (elt (send *msg* :boxes) 0))
;(solve-ik! *robot* (compute-pos-boxtop msg-box) #f(0 1.3 0) :rotation-axis t)
;(show *robot*)
;(send *ri* :angle-vector (send *robot* :angle-vector) 5000)
