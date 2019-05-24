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

// note that cannot use std::function beacause ros uses boost
boost::function<void(const sensor_msgs::Image&)> gen_callback(ros::Publisher pub_image){
  auto predicate = gen_hsi_filter(-100.0, 100.0, 0.3, 1.0, 0.5, 0.8);
  cv::Mat img_filtered_referece;
  bool isInit = true;

  // closure using lambda
  auto fn_callback = [=](const sensor_msgs::Image& img) mutable {
    cv_bridge::CvImageConstPtr cv_ptr = cv_bridge::toCvCopy(img, sensor_msgs::image_encodings::BGR8);
    auto img_filtered_received = convert_bf(cv_ptr->image, predicate);
    if(isInit){
      img_filtered_referece = img_filtered_received;
      isInit = false;
    }else{
      //int cost = compute_cost(img_filtered_referece, img_filtered_received);
      auto img_diff = diff_image(img_filtered_referece, img_filtered_received);
      sensor_msgs::ImagePtr msg_debug = cv_bridge::CvImage(std_msgs::Header(), "bgr8", img_diff).toImageMsg();
      pub_image.publish(msg_debug);
      std::cout << "published" << std::endl;
    }
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
  ros::Publisher pub = n.advertise<sensor_msgs::Image>("/debug_image", 1000);
  ros::Subscriber sub = n.subscribe<sensor_msgs::Image>("/kinect_head/rgb/image_raw", 1000, gen_callback(pub));
  ros::spin();
  return 0;
}
