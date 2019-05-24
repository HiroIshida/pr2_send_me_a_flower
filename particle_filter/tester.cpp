#include <ros/ros.h>
#include "std_msgs/String.h"
#include "sensor_msgs/Image.h"
#include <sstream>
#include <cv_bridge/cv_bridge.h>
#include <sensor_msgs/image_encodings.h>
#include "image_dif.hpp"
#include <boost/function.hpp> 
// write by class
//http://wiki.ros.org/cv_bridge/Tutorials/UsingCvBridgeToConvertBetweenROSImagesAndOpenCVImages
// write by lambda
//https://stackoverflow.com/questions/45340189/ros-use-lambda-as-callback-in-nodehandle-subscribe

boost::function<void(const sensor_msgs::Image&)> gen_callback(){
  cv::Mat img_ref = cv::imread("/home/h-ishida/catkin_ws/src/pr2_send_me_a_flower/particle_filter/image/pre.png", CV_LOAD_IMAGE_COLOR);

  auto fn_callback = [=](const sensor_msgs::Image& img){
    cv_bridge::CvImageConstPtr cv_ptr = cv_bridge::toCvCopy(img, sensor_msgs::image_encodings::BGR8);
    auto predicate = gen_hsi_filter(-100.0, 100.0, 0.3, 1.0, 0.5, 0.8);
    auto img_filtered_referece = convert_bf(img_ref, predicate);
    auto img_filtered_received = convert_bf(cv_ptr->image, predicate);
    int cost = compute_cost(img_filtered_referece, img_filtered_received);
    std::cout<< cost <<std::endl;
  };

  return fn_callback;
}

int main(int argc, char **argv)
{ 
  ros::init(argc, argv, "tester");
  ros::NodeHandle n;
  boost::function<void(const sensor_msgs::Image&)> callback = 
    [&](const sensor_msgs::Image& msg){
      std::cout<<"aaa"<<std::endl;
    };
  auto sub = n.subscribe<sensor_msgs::Image>("/kinect_head/rgb/image_raw", 1000, gen_callback());
  ros::spin();
  return 0;
}
