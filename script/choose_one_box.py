#!/usr/bin/env python
import rospy
import numpy as np
from jsk_recognition_msgs.msg import BoundingBoxArray
from pr2_send_flower.srv import *
from geometry_msgs.msg import Point

bboxes = BoundingBoxArray()

def callback_boxes(msg):
    global bboxes
    bboxes = msg
sub = rospy.Subscriber('core/boxes', BoundingBoxArray, callback_boxes)


def handle_request(req):

    def boxmsg2pos(boxmsg):
        posmsg = boxmsg.pose.position
        pos = np.array([posmsg.x, posmsg.y, posmsg.z])
        return pos

    vase_pos = np.array([0.51, 0.0, 0.7])

    global bboxes
    while(True):
        pos_box_valid_lst = []
        for boxmsg in bboxes.boxes:
            pos_box = boxmsg2pos(boxmsg)
            if np.linalg.norm(pos_box - vase_pos)<0.3:
                pos_box_valid_lst.append(pos_box)
        if len(pos_box_valid_lst)>0:
            break

    # choose the one closest to left arm 
    idx_left = np.argmax([pos[1] for pos in pos_box_valid_lst])
    pos_reach_ = pos_box_valid_lst[idx_left]
    pos_reach = Point()
    pos_reach.x = pos_reach_[0]
    pos_reach.y = pos_reach_[1]
    pos_reach.z = pos_reach_[2]
    return ReachPointResponse(position = pos_reach)


rospy.init_node('choose_one_box', anonymous=True)
sr = rospy.Service('pos_reach_service', ReachPoint, handle_request)
rospy.spin()
