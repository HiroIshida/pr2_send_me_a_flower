#!/usr/bin/env python
import rospy
from jsk_recognition_msgs.msg import PolygonArray
from jsk_recognition_msgs.msg import BoundingBoxArray
from jsk_recognition_msgs.msg import BoundingBox
import tf
import numpy as np
from numpy.linalg import inv
scaler = 1

rospy.init_node("make_collision_cubes")
tf_listerner = tf.TransformListener()

def quaternion2matrix(q):
    q1 = q[0]
    q2 = q[1]
    q3 = q[2]
    q4 = q[3]
    mat = np.matrix([
        [q1**2-q2**2-q3**2+q4**2, 2*(q1*q2+q3*q4), 2*(q3*q1-q2*q4)],
        [2*(q1*q2-q3*q4), q2**2-q3**2-q1**2+q4**2, 2*(q2*q3+q1*q4)],
        [2*(q3*q1+q2*q4), 2*(q2*q3-q1*q4), q3**2-q1**2-q2**2+q4**2]
        ])
    return mat






def polygon2box(polygon, header, trans, rot):
    pts_ = polygon.points
    pts = []
    for pt_ in pts_:
        M_rot = inv(quaternion2matrix(rot))
        pt_np_ = np.array([pt_.x, pt_.y, pt_.z]) 
        pt = M_rot.dot(pt_np_).A1 + np.array(trans)
        pts.append(pt)
    n_pts = len(pts)

    x_lst = [pt[0] for pt in pts]
    y_lst = [pt[1] for pt in pts]
    z_lst = [pt[2] for pt in pts]

    x_min = min(x_lst)
    x_max = max(x_lst)
    y_min = min(y_lst)
    y_max = max(y_lst)

    z_plane = max(z_lst)
    z_max = max([z_plane, 0])
    z_min = min([z_plane, 0])

    bbox = BoundingBox()
    bbox.pose.position.x = (x_min + x_max)*0.5*scaler 
    bbox.pose.position.y = (y_min + y_max)*0.5*scaler 
    bbox.pose.position.z = (z_min + z_max)*0.5*scaler 
    bbox.dimensions.x = (x_max - x_min)*scaler
    bbox.dimensions.y = (y_max - y_min)*scaler
    bbox.dimensions.z = (z_max - z_min)*scaler
    bbox.header = header
    return bbox

pub = rospy.Publisher('/plane2box/output', BoundingBoxArray)

def callback(msg):
    polygons = msg.polygons
    header = msg.header
    (trans, rot) = tf_listerner.lookupTransform(msg.header.frame_id, '/base_link', rospy.Time(0))
    #header.frame_id = "/base_link"

    boxes = []
    for polystump in polygons:
        polygon = polystump.polygon
        bbox = polygon2box(polygon, header, trans, rot)
        boxes.append(bbox)
    bbox_array = BoundingBoxArray()
    bbox_array.boxes = boxes
    bbox_array.header = header
    pub.publish(bbox_array)
    print "published"

sub = rospy.Subscriber('/vase_detection/multi_plane_estimate/output_polygon', PolygonArray, callback)
print "node start"
rospy.spin()
