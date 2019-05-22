#include <opencv2/opencv.hpp>
#include <iostream>
#include <cmath>
#define print(a) cout<<a<<endl
using namespace std;
cv::Vec3f bgr2hsi(cv::Vec3b bgr);
int main()
{ cv::Mat img = cv::imread("image/pre.png", CV_LOAD_IMAGE_COLOR);
  for (int i = 0; i<img.rows; i++){
    for (int j = 0; j<img.rows; j++){
      auto bgr = img.at<cv::Vec3b>(i, j);
      auto hsi = bgr2hsi(bgr);
      print(hsi.val[2]);
    }
  }
}

//https://docs.opencv.org/2.4/modules/core/doc/basic_structures.html#vec
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
