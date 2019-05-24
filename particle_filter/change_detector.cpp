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
  ros::Publisher pub_cost, pub_cost_diff, pub_max_cost_diff, pub_image;
  ros::Subscriber sub_image;
  ros::ServiceServer service_init;

  int cost_reference;
  int cost_pre;
  int max_cost_diff;
  cv::Mat img_reference;
  bool isInit_ref_image;
  bool isInit_ref_cost;
  bool isInit_cost_pre;

public:
    ChangeDetector();

private:
    void init_common();
    void callback(const sensor_msgs::Image& msg);
    bool req_handler(std_srvs::Empty::Request& req, std_srvs::Empty::Response& res);
};

ChangeDetector::ChangeDetector(){
  pub_cost = nh.advertise<std_msgs::Int64>("/cost", 1);
  pub_cost_diff = nh.advertise<std_msgs::Int64>("/cost_diff", 1);
  pub_max_cost_diff = nh.advertise<std_msgs::Int64>("/max_cost_diff", 1);
  pub_image = nh.advertise<sensor_msgs::Image>("/debug_image", 1);
  sub_image = nh.subscribe("/kinect_head/rgb/image_raw", 1, &ChangeDetector::callback, this);
  service_init = nh.advertiseService("trigger_change_detector_init", &ChangeDetector::req_handler, this);
  init_common();
}

void ChangeDetector::init_common()
{
  isInit_ref_image = true;
  isInit_ref_cost = true;
  isInit_cost_pre = true;
  max_cost_diff = 0;
}

bool ChangeDetector::req_handler(std_srvs::Empty::Request& req, std_srvs::Empty::Response& res)
{
  ROS_INFO("received trigger");
  init_common();
}

void ChangeDetector::callback(const sensor_msgs::Image& msg)
{
  cv_bridge::CvImageConstPtr cv_ptr = cv_bridge::toCvCopy(msg, sensor_msgs::image_encodings::BGR8);
  auto predicate = gen_hsi_filter(-100.0, 100.0, 0.3, 1.0, 0.5, 0.88);
  auto img_received = convert_bf(cv_ptr->image, predicate);
  if(isInit_ref_image){
    img_reference = img_received;
    isInit_ref_image = false;

  }else{

    int cost = compute_cost(img_reference, img_received);

    if(isInit_ref_cost){
      cost_reference = cost;
      isInit_ref_cost = false;

    }else{

      if(isInit_cost_pre){
        cost_pre = cost;
        isInit_cost_pre = false;

      }else{
        auto img_diff = diff_image(img_reference, img_received);
        sensor_msgs::ImagePtr msg_debug = cv_bridge::CvImage(std_msgs::Header(), "bgr8", img_diff).toImageMsg();
        std_msgs::Int64 msg_cost, msg_cost_diff, msg_max_cost_diff;

        int cost_diff = abs(cost - cost_reference);
        max_cost_diff = (cost_diff > max_cost_diff) ? cost_diff : max_cost_diff;

        msg_cost.data = cost_diff;
        msg_cost_diff.data = cost_diff;
        msg_max_cost_diff.data = max_cost_diff;

        pub_image.publish(msg_debug);
        pub_cost.publish(msg_cost);
        pub_cost_diff.publish(msg_cost_diff);
        pub_max_cost_diff.publish(msg_max_cost_diff);

        cost_pre = cost;
      }
    }
  }
}

int main(int argc, char **argv)
{
  ros::init(argc, argv, "change_detector");
  ChangeDetector cb;
  ros::spin();
  return 0;
}
