#!/usr/bin/env python
import rospy
from std_msgs.msg import Header
from jsk_recognition_msgs.msg import PolygonArray
from jsk_recognition_msgs.msg import BoundingBoxArray
from jsk_recognition_msgs.msg import BoundingBox
from sensor_msgs.msg import PointCloud
from std_msgs.msg import Float64

import tf
import numpy as np
from numpy.linalg import inv
scaler = 1

name_node = "table_detector"
name_pub1 = name_node + "/box"
name_pub2 = name_node + "/height_top"
name_pub3 = name_node + "/height_top_average"

rospy.init_node(name_node)
pub1 = rospy.Publisher(name_pub1, BoundingBox, queue_size=1)
pub2 = rospy.Publisher(name_pub2, Float64, queue_size=1)
#pub3 = rospy.Publisher(name_pub3, float64, queue_size=1)
tf_listerner = tf.TransformListener()

def polygon2pointcloud(polygon, header):
    pc_polygon = PointCloud()
    pc_polygon.points = polygon.points
    pc_polygon.header = header
    return pc_polygon

def polygon2box(polygon, header_pre, header_new):
    pc_polygon_source = polygon2pointcloud(polygon, header_pre)
    pc_polygon_target = tf_listerner.transformPointCloud(header_new.frame_id, pc_polygon_source)
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
    bbox.header = header_new
    return bbox

def choose_highest_box(bbox_array):#higest wrt base link
    inf = 1000000000
    z_max = -inf
    bbox_highest = BoundingBox()
    for bbox in bbox_array.boxes:
        z_box = bbox.pose.position.z + bbox.dimensions.z * 0.5
        if z_box > z_max:
            bbox_highest = bbox
            z_max = z_box
    return bbox_highest


def callback(msg):
    polygons = msg.polygons
    header_pre = msg.header
    header_new = Header(stamp = header_pre.stamp, frame_id = '/base_link')

    # apply polygon2box to all boxes
    boxes = []
    for polystump in polygons:
        polygon = polystump.polygon
        bbox = polygon2box(polygon, header_pre, header_new)
        boxes.append(bbox)
    bbox_array = BoundingBoxArray()
    bbox_array.boxes = boxes
    bbox_array.header = header_new

    # find box of table and publish relevant topics
    bbox_table = choose_highest_box(bbox_array)
    """
    height_top = Float64()
    height_top.data = bbox_table.dimensions.z
    """
    height_top = bbox_table.dimensions.z
    pub1.publish(bbox_table)
    pub2.publish(height_top)

sub = rospy.Subscriber('/core/multi_plane_estimate/output_polygon', PolygonArray, callback)
rospy.spin()

