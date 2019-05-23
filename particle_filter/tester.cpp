#include "ros/ros.h"
#include "std_msgs/String.h"
#include <sstream>
#include <opencv2/opencv.hpp>
#include <iostream>
#include <functional>
#include <cmath>

cv::Vec3f bgr2hsi(cv::Vec3b bgr);
cv::Mat convert_bf(const cv::Mat& img, std::function<bool(cv::Vec3b)> predicate);
int compute_cost(cv::Mat img1, cv::Mat img2);
std::function<bool(cv::Vec3b)> gen_hsi_filter(
    float h_min, float h_max,
    float s_min, float s_max,
    float i_min, float i_max);

/**
 * This tutorial demonstrates simple sending of messages over the ROS system.
 */
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

cv::Vec3f bgr2hsi(cv::Vec3b bgr)
{
  float B = bgr.val[0]/255.0;
  float G = bgr.val[1]/255.0;
  float R = bgr.val[2]/255.0;
  float I = (R + G + B)/3.0;
  float S = 1.0 - std::min({B, G, R})/I;
  float H = acos(0.5*((R-G)+(R-B))/sqrt((R-G)*(R-G)+(R-B)*(G-B)));
  if(B>G){
    H = 2*3.1415 - H;
  }
  cv::Vec3f hsi(H, S, I);
  return hsi;
}

cv::Mat convert_bf(const cv::Mat& img, std::function<bool(cv::Vec3b)> predicate)
{
  cv::Mat img_bf(img.rows, img.cols, CV_8UC3); // CV_8UC3 really?
  for (int i = 0; i < img.rows; i++){
    for (int j = 0; j < img.cols; j++){
      auto bgr = img.at<cv::Vec3b>(i, j);
      auto bgr_white = cv::Vec3b(255, 255, 255);
      auto bgr_black = cv::Vec3b(0, 0, 0);
      img_bf.at<cv::Vec3b>(i, j) = predicate(bgr) ? bgr_white : bgr_black;
    }
  }
  return img_bf;
}

std::function<bool(cv::Vec3b)> gen_hsi_filter(
    float h_min, float h_max,
    float s_min, float s_max,
    float i_min, float i_max)
{
  auto predicate = [&](cv::Vec3b bgr){
    auto hsi = bgr2hsi(bgr);
    float h = hsi.val[0];
    float s = hsi.val[1];
    float i = hsi.val[2];
    if(h < h_min || h_max < h) {return false;}
    if(s < s_min || s_max < s) {return false;}
    if(i < i_min || i_max < i) {return false;}
    return true;
  };
  return predicate;
}

int compute_cost(cv::Mat img1, cv::Mat img2)
{
  int cost = 0;
  for (int i = 0; i < img1.rows; i++){
    for (int j = 0; j < img1.cols; j++){
      auto bgr1 = img1.at<cv::Vec3b>(i, j);
      auto bgr2 = img2.at<cv::Vec3b>(i, j);
      if (cv::sum(bgr1) != cv::sum(bgr2)){cost++;}
    }
  }
  return cost;
}
