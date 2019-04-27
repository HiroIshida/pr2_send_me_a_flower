#include "ros/ros.h"
#include "jsk_recognition_msgs/PolygonArray.h"
#include "jsk_recognition_msgs/BoundingBoxArray.h"
#include "jsk_recognition_msgs/BoundingBox.h"
#include "tf/transform_listener.h"

tf::TransformListener tflistener;
void callback(const jsk_recognition_msgs::PolygonArray::ConstPtr& msg)
{
  ROS_INFO("r");
}

int main(int argc, char **argv)
{
  ros::init(argc, argv, "make_collision_cubes");
  ros::NodeHandle n;
  ros::Subscriber sub = n.subscribe("/vase_detection/multi_plane_estimate/output_polygon", 1, callback);
  ros::spin();
  return 0;
}
