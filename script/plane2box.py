#!/usr/bin/env python
import rospy
from jsk_recognition_msgs.msg import PolygonArray
from jsk_recognition_msgs.msg import BoundingBoxArray
from jsk_recognition_msgs.msg import BoundingBox
scaler = 1

rospy.init_node("make_collision_cubes")

def polygon2box(polygon, header):
    pts = polygon.points
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
    bbox.header = header
    return bbox

pub = rospy.Publisher('/plane2box/output', BoundingBoxArray)

def callback(msg):
    polygons = msg.polygons
    header = msg.header
    #header.frame_id = "/base_link"

    boxes = []
    for polystump in polygons:
        polygon = polystump.polygon
        bbox = polygon2box(polygon, header)
        boxes.append(bbox)
    bbox_array = BoundingBoxArray()
    bbox_array.boxes = boxes
    bbox_array.header = header
    pub.publish(bbox_array)
    print "published"

sub = rospy.Subscriber('/vase_detection/multi_plane_estimate/output_polygon', PolygonArray, callback)
print "node start"
rospy.spin()
