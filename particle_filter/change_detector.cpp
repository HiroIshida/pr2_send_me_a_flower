#include <ros/ros.h>
#include "std_msgs/String.h"
#include "sensor_msgs/Image.h"
#include "std_msgs/Int64.h"
#include "std_srvs/Empty.h"
#include <sstream>
#include <cv_bridge/cv_bridge.h>
#include <sensor_msgs/image_encodings.h>
#include "image_dif.hpp"
#include <boost/function.hpp> 
// as for use callback function of class member functions...
// https://answers.ros.org/question/108551/using-subscribercallback-function-inside-of-a-class-c/

class ChangeDetector {

  ros::NodeHandle nh;
  ros::Publisher pub_cost, pub_image;
  ros::Subscriber sub_image;
  ros::ServiceServer service_init;

  int cost_ref;
  cv::Mat img_ref;
  bool isInit_ref_image;
  bool isInit_ref_cost;

public:
    ChangeDetector();

private:
    void callback(const sensor_msgs::Image& msg);
    bool triger(std_srvs::Empty::Request& req, std_srvs::Empty::Response& res);
};

ChangeDetector::ChangeDetector(){
  pub_cost = nh.advertise<std_msgs::Int64>("/cost_image_diff", 1);
  pub_image = nh.advertise<sensor_msgs::Image>("/debug_image", 1);
  sub_image = nh.subscribe("/kinect_head/rgb/image_raw", 1000, &ChangeDetector::callback, this);
  service_init = nh.advertiseService("init_triger", &ChangeDetector::triger, this);
  isInit_ref_image = true;
  isInit_ref_cost = true;
}

bool ChangeDetector::triger(std_srvs::Empty::Request& req, std_srvs::Empty::Response& res)
{
  isInit_ref_image = true;
  isInit_ref_cost = true;
}

void ChangeDetector::callback(const sensor_msgs::Image& msg)
{
  cv_bridge::CvImageConstPtr cv_ptr = cv_bridge::toCvCopy(msg, sensor_msgs::image_encodings::BGR8);
  auto predicate = gen_hsi_filter(-100.0, 100.0, 0.3, 1.0, 0.5, 0.8);
  auto image_recieved = convert_bf(cv_ptr->image, predicate);
}

int main(int argc, char **argv)
{
  ros::init(argc, argv, "change_detector");
  ChangeDetector cb;
  ros::spin();
  return 0;
}
