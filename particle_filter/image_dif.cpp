// about data type, (eg. what does CV_64S1 referes to )
//https://docs.opencv.org/2.4/modules/core/doc/basic_structures.html#vec
// find data type of mat in opencv
// https://codeyarns.com/2015/08/27/depth-and-type-of-matrix-in-opencv/

#include "image_dif.hpp"

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
  auto predicate = [=](cv::Vec3b bgr){
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





