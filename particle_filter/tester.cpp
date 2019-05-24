#include <ros/ros.h>
#include "std_msgs/String.h"
#include "sensor_msgs/Image.h"
#include "std_msgs/Int64.h"
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
boost::function<void(const sensor_msgs::Image&)> gen_callback(
    ros::Publisher pub_image,
    ros::Publisher pub_cost
    ){
  auto predicate = gen_hsi_filter(-100.0, 100.0, 0.3, 1.0, 0.5, 0.8);
  cv::Mat img_filtered_referece;
  int cost_reference;
  bool isInit_ref_image = true;
  bool isInit_ref_cost = true;

  // closure using lambda
  auto fn_callback = [=](const sensor_msgs::Image& img) mutable {
    cv_bridge::CvImageConstPtr cv_ptr = cv_bridge::toCvCopy(img, sensor_msgs::image_encodings::BGR8);
    auto img_filtered_received = convert_bf(cv_ptr->image, predicate);

    if(isInit_ref_image){
      img_filtered_referece = img_filtered_received;
      isInit_ref_image = false;
    }else{
      int cost = compute_cost(img_filtered_referece, img_filtered_received);
      if(isInit_ref_cost){
        cost_reference = cost;
        isInit_ref_cost = false;
      }else{
        auto img_diff = diff_image(img_filtered_referece, img_filtered_received);
        sensor_msgs::ImagePtr msg_debug = cv_bridge::CvImage(std_msgs::Header(), "bgr8", img_diff).toImageMsg();
        std_msgs::Int64 msg_cost;
        msg_cost.data = abs(cost - cost_reference);
        pub_image.publish(msg_debug);
        pub_cost.publish(msg_cost);
      }
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
  ros::Publisher pub_image = n.advertise<sensor_msgs::Image>("/debug_image", 1);
  ros::Publisher pub_cost = n.advertise<std_msgs::Int64>("/cost_image_diff", 1);
  ros::Subscriber sub = n.subscribe<sensor_msgs::Image>("/kinect_head/rgb/image_raw", 1, gen_callback(pub_image, pub_cost));
  ros::spin();
  return 0;
}
