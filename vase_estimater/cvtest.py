#!/usr/bin/env python
import rospy
import cv2
from cv_bridge import CvBridge, CvBridgeError
from sensor_msgs.msg import Image
import time
rospy.init_node("cv_test")

class VaseFinder:

    def __init__(self):
        self.bridge = CvBridge()
        label_sub = rospy.Subscriber("/slic_super_pixels/output", Image, self.callback_label)
        label_sub = rospy.Subscriber("/slic_super_pixels/debug/mean_color", Image, self.callback_image_mean)
        image_sub = rospy.Subscriber("/image", Image, self.callback_image)
        self.label = None
        self.image = None
        self.image_mean = None
        self.isDone = False

    def callback_label(self, img_msg):
        self.label = self.bridge.imgmsg_to_cv2(img_msg, "32SC1")
        self.main()

    def callback_image(self, img_msg):
        self.image = self.bridge.imgmsg_to_cv2(img_msg, "bgr8")
        self.main()

    def callback_image_mean(self, img_msg):
        self.image_mean = self.bridge.imgmsg_to_cv2(img_msg, "bgr8")
        self.main()

    def cond_oneshot(self):
        if self.isDone:
            return False
        if self.image is None:
            return False
        if self.image_mean is None:
            return False
        if self.label is None:
            return False
        return True

    def main(self):#one shot
        if not self.cond_oneshot():
            return 
        self.isDone = True
        print "done"

VaseFinder()
rospy.spin()

