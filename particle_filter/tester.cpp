#include <ros/ros.h>
#include "std_msgs/String.h"
#include "sensor_msgs/Image.h"
#include <sstream>
#include "image_dif.hpp"
#include <boost/function.hpp> 
//https://stackoverflow.com/questions/45340189/ros-use-lambda-as-callback-in-nodehandle-subscribe

int main(int argc, char **argv)
{ 
  auto predicate = gen_hsi_filter(-100.0, 100.0, 0.3, 1.0, 0.5, 0.8);
  cv::Mat img1 = cv::imread("image/pre.png", CV_LOAD_IMAGE_COLOR);
  cv::Mat img2 = cv::imread("image/post_with_move.png", CV_LOAD_IMAGE_COLOR);
  cv::Mat img1_filtered = convert_bf(img1, predicate);
  cv::Mat img2_filtered = convert_bf(img2, predicate);

  ros::init(argc, argv, "tester");
  ros::NodeHandle n;
  boost::function<void(const sensor_msgs::Image&)> callback = 
    [&](const sensor_msgs::Image& msg){
      std::cout<<"aaa"<<std::endl;
    };
  auto sub = n.subscribe<sensor_msgs::Image>("/kinect_head/rgb/image_raw", 1000, callback);
  ros::spin();
  return 0;
}
