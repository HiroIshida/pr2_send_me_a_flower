#!/usr/bin/env python
import rospy
import time
import tf
import numpy as np
from std_msgs.msg import String
from std_msgs.msg import Float64
from std_msgs.msg import Time
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

inf = 1000000000000000000
bbox_flower = BoundingBox()
h_table = inf
def callback_height_top(h):
    global h_table
    h_table = h.data
sub = rospy.Subscriber('/table_detector/height_top', Float64, callback_height_top)

def callback_largest_box(bbox_array):
    def calc_volume(bbox):
        size = bbox.dimensions
        return size.x * size.y * size.z
    vol_lst = [calc_volume(bbox) for bbox in bbox_array.boxes]
    idx_largest = np.argmax(vol_lst)
    global bbox_flower
    bbox_flower = bbox_array.boxes[idx_largest]
sub = rospy.Subscriber('/vase_detection/boxes', BoundingBoxArray, callback_largest_box)

def handle_request(req):

    global h_table
    global bbox_flower
    # will be concise if use ros service

    def receivedBothData(bbox_flower, h_table):
        boolean = (
                (bbox_flower.header.frame_id != '')  
                and
                (h_table != inf)
                )
        print (bbox_flower.header.frame_id != '')
        print (h_table != inf)
        return boolean

    while not receivedBothData(bbox_flower, h_table):
        time.sleep(0.001)
        print "waiting..."
    print "received"
    print h_table

    p_reach = Point()
    p_reach.x = bbox_flower.pose.position.x
    p_reach.y = bbox_flower.pose.position.y
    p_reach.z = h_table
    return ReachPointResponse(position = p_reach)

sr = rospy.Service('trigger', ReachPoint, handle_request)
rospy.spin()
