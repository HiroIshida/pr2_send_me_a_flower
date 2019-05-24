#include <ros/ros.h>
#include "std_msgs/String.h"
#include "sensor_msgs/Image.h"
#include "std_msgs/Int64.h"
#include <sstream>
#include <cv_bridge/cv_bridge.h>
#include <sensor_msgs/image_encodings.h>
#include "image_dif.hpp"
#include <boost/function.hpp> 

class ChangeDetector
{
  ros::NodeHandle nh;
  ros::Publisher pub_cost;

  public:
  ChangeDetector()
  {
    pub_cost = nh.advertise<std_msgs::Int64>("/cost_image_diff", 1);
  }
};
int main(int argc, char **argv)
{
  ros::init(argc, argv, "change_detector");
  ChangeDetector cb();
  ros::spin();
  return 0;
}
