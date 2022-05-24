
#include <stdio.h>
#include <stdlib.h>
#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/imgproc.hpp>
#include <math.h>
#include <iostream>
#include <Magick++.h>
#include <tesseract/baseapi.h>
#include <tesseract/renderer.h>
#include <leptonica/allheaders.h>
#include <windows.h>
#include <winsock.h>
#include <WS2tcpip.h>
#include <string>

#pragma comment (lib, "Ws2_32.lib")

#define DEFAULT_PORT "10050"


using namespace std;
using namespace cv;
using namespace Magick;
using namespace tesseract;

float w = 1050, h = 1200;
Mat img, imgGray, imgBlur, imgCanny, imgDil, imgResize, imgPrep, imgCont, matrix, imgWarp, imgWarped;

vector < cv::Point > initialPoints, docPoints;

//~~~~document Resize(May not be needed)~~~~//
Mat docResize(Mat img)
{
	resize(img, imgResize, Size(), 1, 1); //by scale resize

	return imgResize;
}

//~~~~Document Prepping~~~~//
Mat docPrep(Mat img)
{
	cvtColor(img, imgGray, COLOR_BGR2GRAY);
	GaussianBlur(imgGray, imgBlur, Size(3, 3), 3, 0);
	
	/*int thres1 = 30, thres2 = 65;
	namedWindow("Trackbars", (840, 200));
	createTrackbar("Threshold 1", "Trackbars", &thres1, 175);
	createTrackbar("Threshold 2", "Trackbars", &thres2, 175)*/;

	Canny(imgBlur, imgCanny, 30, 65);
	Mat kernel = getStructuringElement(MORPH_RECT, Size(3, 3));
	dilate(imgCanny, imgDil, kernel);

	/*while (true)
	{
		Canny(imgBlur, imgCanny, thres1, thres2);

		Mat kernel = getStructuringElement(MORPH_RECT, Size(3, 3));
		dilate(imgCanny, imgDil, kernel);
		imshow("Image in docPrep", imgResize);
     	imshow("Image Gray", imgGray);
		imshow("Image Blur", imgBlur);
		imshow("Image Canny", imgCanny);
		imshow("Image Dilation", imgDil);
		waitKey(1);
	}*/

	return imgDil;

}

//~~~~Document Contours~~~~//
vector<cv::Point> docContours(Mat imgC)
{
	vector<vector<cv::Point>> contours;
	vector<Vec4i> hierarchy;

	findContours(imgC, contours, hierarchy, RETR_EXTERNAL, CHAIN_APPROX_SIMPLE);

	vector<vector<cv::Point>> conPoly(contours.size());
	vector<Rect> boundRect(contours.size());

	vector<cv::Point> biggest;//grabs the edge points of the biggest rectangle
	int MaxArea = 0;

	for (int i = 0; i < contours.size(); i++)
	{
		int area = contourArea(contours[i]);
		//cout << area << endl;

		if (area > 25000)
		{
			float peri = arcLength(contours[i], true);
			approxPolyDP(contours[i], conPoly[i], 0.02 * peri, true);

			if (area > MaxArea && conPoly[i].size() == 4)
			{
				drawContours(imgResize, conPoly, i, Scalar(255, 255, 0), 5); //look at contour drawn in page
				biggest = { conPoly[i][0],conPoly[i][1], conPoly[i][2], conPoly[i][3] };
				MaxArea = area;

			}
		}
	}
	return biggest;
}

//--draw edge points--//
void drawPoints(vector<cv::Point> points, Scalar color)
{
	for (int i = 0; i < points.size(); i++)
	{
		circle(imgResize, points[i], 5, color, FILLED);
		putText(imgResize, to_string(i), points[i], FONT_HERSHEY_PLAIN, 4, color, 4);
	}
}

//--reorder edge points--//
vector<cv::Point> reorder(vector<cv::Point> points)
{
	vector<cv::Point> newPoints;
	vector<int> sumPoints, subPoints;

	for (int i = 0; i < 4; i++)
	{
		sumPoints.push_back(points[i].x + points[i].y);
		subPoints.push_back(points[i].x - points[i].y);
	}

	newPoints.push_back(points[min_element(sumPoints.begin(), sumPoints.end()) - sumPoints.begin()]); //point 0
	newPoints.push_back(points[max_element(subPoints.begin(), subPoints.end()) - subPoints.begin()]); //point 1
	newPoints.push_back(points[min_element(subPoints.begin(), subPoints.end()) - subPoints.begin()]);//point 2
	newPoints.push_back(points[max_element(sumPoints.begin(), sumPoints.end()) - sumPoints.begin()]); //point 3

	return newPoints;
}

//~~~~Document Wapring(Flat)~~~~//
Mat docWarp(Mat img, vector<cv::Point> points)
{
	Point2f src[4] = { points[0],points[1],points[2],points[3] }; //floating points
	Point2f dst[4] = { {0.0f,0.0f}, {w,0.0f}, {0.0f,h}, {w,h} }; //source point

	matrix = getPerspectiveTransform(src, dst);
	warpPerspective(img, imgWarp, matrix, cv::Point(w, h));

	return imgWarp;
}

int main(int argc, char** argv)
{
	VideoCapture cap(1);
	Mat img;
	WSADATA wsaData;
	int iResult;

	SOCKET ListenSocket = INVALID_SOCKET;
	SOCKET ClientSocket = INVALID_SOCKET;

	struct addrinfo* result = NULL;
	struct addrinfo hints;

	int iSendResult;

	iResult = WSAStartup(MAKEWORD(2, 2), &wsaData);

	ZeroMemory(&hints, sizeof(hints));
	hints.ai_family = AF_INET;
	hints.ai_socktype = SOCK_STREAM;
	hints.ai_protocol = IPPROTO_TCP;
	hints.ai_flags = AI_PASSIVE;

	iResult = getaddrinfo(NULL, DEFAULT_PORT, &hints, &result);

	ListenSocket = socket(result->ai_family, result->ai_socktype, result->ai_protocol);

	iResult = bind( ListenSocket, result->ai_addr, (int)result->ai_addrlen);

	while (true) {

		cap.read(img);
		
		//~~image resize~~//
		docResize(img);
		

		//~~prep method~~//
		imgPrep = docPrep(imgResize);

		//~~contour methods~~//
		initialPoints = docContours(imgPrep);
		drawPoints(initialPoints, Scalar(0, 0, 255)); //unsorted points
		cout << initialPoints <<endl;
		
		//imshow("Image", img);
		//imshow("Image Dilation", imgPrep);
		//imshow("Image Warp", imgWarped);
		//waitKey(0);

		if (initialPoints.size() !=0) {

			docPoints = reorder(initialPoints);
			drawPoints(docPoints, Scalar(0, 255, 255)); //sorted points
			imgWarped = docWarp(imgResize, docPoints);
			imshow("Imgae Warped", imgWarped);
		}
		//~~warp method~~//
		imshow("Image", imgResize);
		imshow("Image Warped", imgPrep);
		waitKey(1);
	}
	//string path = "test19.jpg";
	//img = imread(path);

	//~~image resize~~//
	docResize(img);

	//~~prep method~~//
	imgPrep = docPrep(imgResize);

	//~~contour methods~~//
	initialPoints = docContours(imgPrep);
	//drawPoints(initialPoints, Scalar(0, 0, 255)); //unsorted points

	//imshow("Image", img);
	//imshow("Image Dilation", imgPrep);
	////imshow("Image Warp", imgWarped);
	//waitKey(0);

	docPoints = reorder(initialPoints);
	//drawPoints(docPoints, Scalar(0, 255, 255)); //sorted points

	//~~warp method~~//
	imgWarped = docWarp(imgResize, docPoints);
	string endpath = "Finished.jpg";
	imwrite(endpath, imgWarped);

	

		InitializeMagick(*argv);
   // Construct the image object. Seperating image construction from the 
  //the read operation ensures that a failure to read the image file 
  // doesn't render the image object useless. 
    Image image;
    
        // Read a file into image object 
       image.read(endpath);

        // Crop the image to specified size (width, height, xOffset, yOffset)
        image.sharpen(0, 0.5);

        // Write the image to a file 
        const char* Path = "D:\\OpenCVTests\\The real one\\opencv_1\\logo123.png";
        image.write(Path);
    
   const char* output_base = "my_first_tesset_pdf";
    const char* datapath = "D:\\OpenCVTests\\The real one\\opencv_1";
    int timeout_ms = 5000;
    const char* retry_config = nullptr;
    bool textonly = false;
    int jpg_quality = 92;

    TessBaseAPI *api = new TessBaseAPI();
    if (api->Init(datapath, "eng")) 
    {
        fprintf(stderr, "Could not initialize tesseract.\n");
        exit(1);
    }

    TessPDFRenderer *renderer = new TessPDFRenderer(
        output_base, api->GetDatapath());

    bool succeed = api->ProcessPages(Path, retry_config, timeout_ms, renderer);
    if (!succeed) 
    {
        fprintf(stderr, "Error during processing.\n");
        return EXIT_FAILURE;
    }
    api->End();
    return EXIT_SUCCESS;
}