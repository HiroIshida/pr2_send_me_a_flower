#!/usr/bin/env roseus
(require "package://pr2eus/pr2-interface.l")
(require "models/arrow-object.l")

(ros::roseus "reaching")
(ros::load-ros-manifest "jsk_recognition_msgs")
(ros::load-ros-manifest "roseus")
(print "finish loading")

(pr2-init)
(setq *tfl* (instance ros::transform-listener :init))
(setq *robot* *pr2*)

(defun robot-init! ()
    (send *robot* :reset-manip-pose)
    (send *robot* :l_upper_arm_roll_joint :joint-angle -10)
    (send *robot* :r_upper_arm_roll_joint :joint-angle -10)
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

(defun callback (bbox)
  (let* (ik-pos
         (coords (get-box-global-coords bbox))
         )
    (print "message received")
    (setq ik-pos (send coords :pos)) 
    (solve-ik! ik-pos) ;; somehow (solve-ik (send coords :pos)) doesn't work
    (send *ri* :angle-vector (send *robot* :angle-vector) 8000)
    (send *ri* :wait-interpolation)
    (send *ri* :start-grasp :larm)
    (send *robot* :larm :move-end-pos #f(-300 0 0) :local)
    (send *ri* :angle-vector (send *robot* :angle-vector) 8000)
    ))

(defun solve-ik-pos! (robot pos-reach)
  (send robot :inverse-kinematics (make-coords :pos pos-reach)
        :link-list (send robot :link-list (send robot :larm :end-coords :parent))
        :move-target (send robot :larm :end-coords)
        :rotation-axis nil))

(defun compute-pos-boxtop (bbox)
  (let* (
         (pos-box (send (get-box-global-coords bbox) :pos))
         (pos-boxtop (v+ pos-box #f(0 0 0.3)))
         )
    pos-boxtop
    ))


(setq msg-box (elt (send *msg* :boxes) 0))
(solve-ik-pos! *robot* (compute-pos-boxtop msg-box))



(defun show (robot)
  (objects (list robot)))

(robot-init!)
(send *ri* :angle-vector (send *robot* :angle-vector) 5000)
(print "install loading")
(setq *msg*
      (one-shot-subscribe "/vase_detection/boxes" jsk_recognition_msgs::BoundingBoxArray :after-stamp (ros::time)))
