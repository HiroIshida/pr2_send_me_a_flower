#!/usr/bin/env python
import rospy
from std_msgs.msg import Header
from jsk_recognition_msgs.msg import BoundingBoxArray
from jsk_recognition_msgs.msg import BoundingBox

inf = 1000000000

rospy.init_node("choose_highest_box")
pub = rospy.Publisher('/choose_highest_box/output', BoundingBox, queue_size=1)

def callback(bbox_array):
    z_max = -inf
    bbox_highest = BoundingBox()
    for bbox in bbox_array.boxes:
        z_box = bbox.pose.position.z + bbox.dimensions.z * 0.5
        if z_box > z_max:
            bbox_highest = bbox
            z_max = z_box
    pub.publish(bbox_highest)

sub = rospy.Subscriber('/plane2box/output', BoundingBoxArray, callback)
rospy.spin()






