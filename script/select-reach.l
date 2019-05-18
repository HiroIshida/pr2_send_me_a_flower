#!/usr/bin/env roseus
(load "package://pr2eus/pr2-interface.l")
;(load "package://pr2eus_moveit/euslisp/pr2eus-moveit.l")
(load "util.l")
(pr2-init)
;(send *ri* :set-moveit-environment (instance pr2-moveit-environment :init))

;(ros::roseus "reaching")
(ros::load-ros-manifest "jsk_recognition_msgs")
(ros::load-ros-manifest "roseus")
(print "finish loading")

(print "robot initialized")
(setq *tfl* (instance ros::transform-listener :init))
;(setq *co* (instance collision-object-publisher :init))
(load "ishida-pr2-init.l")

(defun get-box-global-coords (bbox)
  (let* (
         (coords-local (ros::tf-pose->coords (send bbox :pose)))
         (tf-local->global (send *tfl* :lookup-transform "/base_footprint" (send bbox :header :frame_id) (ros::time 0)))
         (print (send bbox :header :frame_id))
         (coords-global (send tf-local->global :transform coords-local))
         )
    coords-global
    ))

(defun compute-pos-boxtop (bbox)
  (let* (
         (pos-box (send (get-box-global-coords bbox) :pos))
         (pos-boxtop (v+ pos-box #f(0 0 0.3)))
         )
    pos-boxtop
    ))

(defun get-flower-position ()
  (let* (
         (msg-box (get-msg "/core/bounding_box_marker/selected_box" jsk_recognition_msgs::BoundingBox))
         (coords-box (get-box-global-coords msg-box))
         (pos-box (send coords-box :pos))
         )
    pos-box
    ))

;(setq *flower-position* (get-flower-position 2))
(defun guide-larm ()
  (let* (
         (pos-flower (get-flower-position))
         (pos-flower-grasp (v+ pos-flower #f(0 0 -30)))
         )
    (setq *pos-grasp* pos-flower-grasp)
    (solve-ik! *robot* (v+ *pos-grasp* #f(0 50 0)) #f(-1.57 0 0) :rotation-axis t)
    (show *robot*)
    ))

(defun shake-larm ()
  (send *robot* :larm :move-end-pos #f(50 0 0) :world)
  (transmit-posture *robot* t)
  (send *robot* :larm :move-end-pos #f(-50 0 0) :world)
  (transmit-posture *robot* t)
  )

(robot-init!)
(transmit-posture t)
;(send *ri* :stop-grasp)
;(guide-larm) 
;(transmit-posture t)
;(send *robot* :larm :move-end-pos #f(0 -50 0) :world)
;(transmit-posture t)
;(send *ri* :start-grasp :larm)
;(shake-larm)
;(send *robot* :larm :move-end-pos #f(0 0 400) :world)
;(transmit-posture t)
;(send *ri* :stop-grasp)
(send *robot* :rarm :move-end-pos #f(0 0 -30) :world)
;(transmit-posture t)
