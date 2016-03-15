#include "opencv2/opencv.hpp"
#include <iostream>

using namespace cv;

static const int VIDEO_DEVICE_ID = 1;

int main(int, char**)
{
    cv::VideoCapture cap(VIDEO_DEVICE_ID);
    if (! cap.isOpened())  // check if we succeeded
    {
        return 1;
    }

    cv::Mat edges;
    cv::namedWindow("edges", 1);

    while (true)
    {
        cv::Mat frame;
        cap >> frame; // get a new frame from camera
        cv::cvtColor(frame, edges, CV_BGR2GRAY);
        cv::GaussianBlur(edges, edges, Size(7, 7), 1.5, 1.5);
        // cv::Canny(edges, edges, 0, 30, 3);
        cv::imshow("edges", edges);
        if (cv::waitKey(30) >= 0)
        {
            break;
        }
        // TODO: also stop if the window has been destroyed
    }
    std::cout << "Done" << std::endl;
    // the camera will be deinitialized automatically in VideoCapture destructor
    return 0;
}
