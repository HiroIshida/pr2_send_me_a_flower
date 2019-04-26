#!/usr/bin/env roseus
(load "package://pr2eus_moveit/euslisp/pr2eus-moveit.l")
(ros::load-ros-manifest "jsk_recognition_msgs")
(ros::load-ros-manifest "roseus")
(ros::roseus "fucker" :anonymous t)

(setq *co* (instance collision-object-publisher :init))
(send *co* :wipe-all)

(defun scaler (l)
  (* 1000 l))
(defun box->cube (bbox)
  (let* (
         (center-box (send (send bbox :pose) :position))
         (center-x (scaler (send center-box :x)))
         (center-y (scaler (send center-box :y)))
         (center-z (scaler (send center-box :z)))
         (width-box (send bbox :dimensions))
         (width-x (scaler (send width-box :x)))
         (width-y (scaler (send width-box :y)))
         (width-z (scaler (send width-box :z)))
         cube)
    (setq cube (make-cube width-x width-y width-z))
    (send cube :translate (float-vector center-x center-y center-z))
    cube
    ))

(defun callback-collision-adder (box-msg)
  (let ((cube (box->cube box-msg)))
    (print "received")
    (send *co* :add-object cube :frame-id "base_footprint"
               :relative-pose (send cube :copy-worldcoords)
               :object-id "cube")))
 
(ros::subscribe "/pickup_highest_box/output" jsk_recognition_msgs::BoundingBox #'callback-collision-adder)


(send *co* :add-object *cube* :frame-id "base_footprint"
           :relative-pose (send *cube* :copy-worldcoords)
           :object-id "cube")

(ros::rate 1)
(do-until-key
(ros::sleep)
(ros::spin-once))
(exit)

