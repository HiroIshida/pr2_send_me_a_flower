#include "ros/ros.h"
#include "std_msgs/String.h"
#include <sstream>
#include "image_dif.hpp"

int main(int argc, char **argv)
{
  auto predicate = gen_hsi_filter(-100.0, 100.0, 0.3, 1.0, 0.5, 0.8);
  cv::Mat img1 = cv::imread("image/pre.png", CV_LOAD_IMAGE_COLOR);
  cv::Mat img2 = cv::imread("image/post_without_move.png", CV_LOAD_IMAGE_COLOR);
  cv::Mat img1_filtered = convert_bf(img1, predicate);
  cv::Mat img2_filtered = convert_bf(img2, predicate);

  ros::init(argc, argv, "tester");
  ros::NodeHandle n;
  ros::Publisher chatter_pub = n.advertise<std_msgs::String>("chatter", 1000);
  ros::Rate loop_rate(10);
  int count = 0;
  while (ros::ok())
  {

    int cost = compute_cost(img1_filtered, img2_filtered);
    std_msgs::String msg;
    std::stringstream ss;
    ss << "hello world " << count;
    msg.data = ss.str();
    ROS_INFO("%s", msg.data.c_str());
    chatter_pub.publish(msg);
    ros::spinOnce();
    loop_rate.sleep();
    ++count;
  }

  return 0;
}
