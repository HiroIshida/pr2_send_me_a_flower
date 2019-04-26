#!/usr/bin/env python
import rospy
from jsk_recognition_msgs.msg import PolygonArray
from jsk_recognition_msgs.msg import BoundingBoxArray
from jsk_recognition_msgs.msg import BoundingBox
from sensor_msgs.msg import PointCloud

import tf
import numpy as np
from numpy.linalg import inv
scaler = 1

rospy.init_node("make_collision_cubes")
tf_listerner = tf.TransformListener()

def polygon2pointcloud(polygon, header):
    pc_polygon = PointCloud()
    pc_polygon.points = polygon.points
    pc_polygon.header = header
    return pc_polygon

def polygon2box(polygon, header_pre):
    pc_polygon_source = polygon2pointcloud(polygon, header_pre)
    pc_polygon_target = tf_listerner.transformPointCloud('/base_link', pc_polygon_source)
    pts = pc_polygon_target.points
    n_pts = len(pts)

    x_lst = [pt.x for pt in pts]
    y_lst = [pt.y for pt in pts]
    z_lst = [pt.z for pt in pts]

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
    bbox.header = header_pre
    return bbox

pub = rospy.Publisher('/plane2box/output', BoundingBoxArray)

def callback(msg):
    polygons = msg.polygons
    header_pre = msg.header
    header_new = header_pre #maybe copy is required
    header_new.frame_id = '/base_link'

    boxes = []
    for polystump in polygons:
        polygon = polystump.polygon
        bbox = polygon2box(polygon, header_new)
        boxes.append(bbox)
    bbox_array = BoundingBoxArray()
    bbox_array.boxes = boxes
    bbox_array.header = header_new
    pub.publish(bbox_array)
    print "published"

sub = rospy.Subscriber('/vase_detection/multi_plane_estimate/output_polygon', PolygonArray, callback)
print "node start"
rospy.spin()

