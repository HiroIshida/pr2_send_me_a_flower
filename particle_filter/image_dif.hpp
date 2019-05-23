
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
