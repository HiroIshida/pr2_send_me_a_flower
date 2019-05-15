#!/usr/bin/env python
import rospy
import time
import tf
import numpy as np
from std_msgs.msg import String
from jsk_recognition_msgs.msg import BoundingBoxArray
from jsk_recognition_msgs.msg import BoundingBox
from sensor_msgs.msg import PointCloud
from geometry_msgs.msg import PointStamped
from geometry_msgs.msg import Point

from std_srvs.srv import Trigger
#from ReachPoint.srv import *
from pr2_send_flower.srv import *

rospy.init_node("vase_reach_point")
tf_listerner = tf.TransformListener()
#pub = rospy.Publisher('/vase_reach_point', Point, queue_size=1)

bbox_largest = BoundingBox()
bbox_table = BoundingBox()

def callback_largest_box(bbox_array):
    def calc_volume(bbox):
        size = bbox.dimensions
        return size.x * size.y * size.z
    vol_lst = [calc_volume(bbox) for bbox in bbox_array.boxes]
    idx_largest = np.argmax(vol_lst)
    global bbox_largest
    bbox_largest = bbox_array.boxes[idx_largest]
sub = rospy.Subscriber('/vase_detection/boxes', BoundingBoxArray, callback_largest_box)

def callback_table_box(bbox):
    global bbox_table
    bbox_table = bbox
sub = rospy.Subscriber('/choose_highest_box/output', BoundingBox, callback_table_box)

def handle_request(req):
    global bbox_largest
    global bbox_table
    # will be concise if use ros service

    def receivedBothData(bbox_largest, bbox_table):
        boolean = (
                (bbox_largest.header.frame_id != '')  
                and
                (bbox_table.header.frame_id != '')
                )
        return boolean

    while not receivedBothData(bbox_largest, bbox_table):
        time.sleep(1)
        print "waiting..."
    print "received"

    # without this, error related to time stump may occur
    bbox_largest.header.stamp = bbox_table.header.stamp

    # as for transform, see:
    # http://docs.ros.org/jade/api/tf/html/python/tf_python.html
    ps_flower_source = PointStamped()
    ps_flower_source.header = bbox_largest.header
    ps_flower_source.point = bbox_table.pose.position
    ps_flower_target = tf_listerner.transformPoint('/base_link', ps_flower_source)
    z_table = bbox_table.dimensions.z * 0.5 + bbox_table.pose.position.z

    p_reach = Point()
    p_reach.x = ps_flower_target.point.x
    p_reach.y = ps_flower_target.point.y
    p_reach.z = z_table
    return ReachPointResponse(position = p_reach)
    #pub.publish(p_reach)

sr = rospy.Service('trigger', ReachPoint, handle_request)
rospy.spin()
