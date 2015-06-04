//
//  ObjectRecognizerViewController.m
//  CvUniversalTest
//
//  Created by Michael Kalinin on 04/06/15.
//  Copyright (c) 2015 Michael. All rights reserved.
//

#import "ObjectRecognizerViewController.h"

#include "opencv2/objdetect/objdetect.hpp"

@interface ObjectRecognizerViewController ()
{
    cv::CascadeClassifier face_cascade;
    cv::CascadeClassifier eyes_cascade;
}

@end

@implementation ObjectRecognizerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupClassifiers];
}

- (void)setupUI
{
    [super setupUI];
    
    // Views
    [self.view addSubview: self.animatedPathView];
    
    // Buttons
    [self addButtons: @[
                        self.undoButton
                        ]];
    
}

#pragma mark - CvVideoCamera

- (void)initCamera
{
    [super initCamera];
    self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;
}

- (void)setupClassifiers
{
    // 1. Load the cascades
    
    NSString* face_cascade_name = [[NSBundle mainBundle] pathForResource:@"haarcascade_frontalface_default" ofType:@"xml"];
    
    if(!face_cascade.load([face_cascade_name UTF8String]))
    {
        NSLog(@"Error loading\n");
    }
    if(!eyes_cascade.load("haarcascade_eye_tree_eyeglasses.xml"))
    {
        NSLog(@"Error loading\n");
    }
}

- (void)processImage:(cv::Mat&)image
{
    if (self.shouldProcessFrames)
    {
        cv::Mat frame = cv::Mat(image);
        [self detectAndShow: frame];
    }
}

- (void)detectAndShow:(cv::Mat&)frame
{
    self.shouldProcessFrames = NO;
    
    std::vector<cv::Rect> faces;
    cv::Mat frame_gray;
    
    cv::cvtColor( frame, frame_gray, CV_BGR2GRAY );
    cv::equalizeHist( frame_gray, frame_gray );
    
    //-- Detect faces
    face_cascade.detectMultiScale( frame_gray, faces, 1.1, 5, 0|CV_HAAR_SCALE_IMAGE, cv::Size(30, 30) );
    
    NSLog(@"Detected faces: %lu", faces.size());
    
    std::vector<cv::Point2f> points;
    
    if (faces.size() > 0)
    {
        cv::Rect rect = faces.at(0);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.animatedPathView setRectForDisplay:rect];
        });
    }
    
    
//    for( size_t i = 0; i < faces.size(); i++ )
//    {
//        cv::Point center( faces[i].x + faces[i].width*0.5, faces[i].y + faces[i].height*0.5 );
//        ellipse( frame, center, cv::Size( faces[i].width*0.5, faces[i].height*0.5), 0, 0, 360, cv::Scalar( 255, 0, 255 ), 4, 8, 0 );
//        
//        cv::Mat faceROI = frame_gray( faces[i] );
//        std::vector<cv::Rect> eyes;
//        
//        //-- In each face, detect eyes
//        eyes_cascade.detectMultiScale( faceROI, eyes, 1.1, 2, 0|CV_HAAR_SCALE_IMAGE, cv::Size(30, 30) );
//        
//        for( size_t j = 0; j < eyes.size(); j++ )
//        {
//            cv::Point center( faces[i].x + eyes[j].x + eyes[j].width*0.5, faces[i].y + eyes[j].y + eyes[j].height*0.5 );
//            int radius = cvRound( (eyes[j].width + eyes[j].height)*0.25 );
//            cv::circle( frame, center, radius, cv::Scalar( 255, 0, 0 ), 4, 8, 0 );
//        }
//    }
    self.shouldProcessFrames = YES;
}


@end
