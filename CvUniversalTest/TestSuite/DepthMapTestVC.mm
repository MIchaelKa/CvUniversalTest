//
//  DepthMapTestVC.m
//  CvUniversalTest
//
//  Created by Michael Kalinin on 25/06/15.
//  Copyright (c) 2015 Michael. All rights reserved.
//

#import "DepthMapTestVC.h"

#import "MWPhotoBrowser.h"
#import "ResultModelViewController.h"

@interface DepthMapTestVC () <MWPhotoBrowserDelegate>
{
    Mat leftImage;
    Mat rightImage;
    
    BOOL leftImageSaved;
}

@property (nonatomic, strong) NSMutableArray *resultImages;
@property (nonatomic, strong) NSMutableArray *resultPoints;

@end

@implementation DepthMapTestVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    leftImageSaved = NO;    
    self.resultImages = [NSMutableArray array];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.resultImages removeAllObjects];
}

#pragma mark - UI

- (void)setupUI
{
    [super setupUI];
    
    // Buttons
    [self addButtons: @[
                        self.undoButton,
                        self.startButton                        
                        ]];
}

- (void)presentResultBrowser
{
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    
    // Set options
    browser.displayActionButton = YES; // Show action button to allow sharing, copying, etc (defaults to YES)
    browser.displayNavArrows = YES; // Whether to display left and right nav arrows on toolbar (defaults to NO)
    browser.displaySelectionButtons = NO; // Whether selection buttons are shown on each image (defaults to NO)
    browser.zoomPhotosToFill = YES; // Images that almost fill the screen will be initially zoomed to fill (defaults to YES)
    browser.alwaysShowControls = NO; // Allows to control whether the bars and controls are always visible or whether they fade away to show the photo full (defaults to NO)
    browser.enableGrid = YES; // Whether to allow the viewing of all the photo thumbnails on a grid (defaults to YES)
    browser.startOnGrid = YES; // Whether to start on the grid of thumbnails instead of the first photo (defaults to NO)
    browser.autoPlayOnAppear = NO; // Auto-play first video
    
    [self.navigationController pushViewController:browser animated:NO];
}

- (void)presentResultModelViewController
{
    ResultModelViewController *resultModelViewController = [[ResultModelViewController alloc] init];
    resultModelViewController.points = self.resultPoints;
    [self.navigationController pushViewController:resultModelViewController animated:NO];
    
}

- (void)startButtonAction
{
    [self computeDepthMap];
    //[self presentResultBrowser];
    [self presentResultModelViewController];
}

- (void)computeDepthMap
{
    
    [self computeDepthMapOpticalFlowWithImages];
}

- (void)computeDepthMapStereoBM
{
    // Call the constructor for StereoBM
    int ndisparities = 112; // Range of disparity
    int SADWindowSize = 9; // Size of the block window. Must be odd
    StereoBM sbm(StereoBM::BASIC_PRESET, ndisparities, SADWindowSize);

    sbm.state->SADWindowSize = 9;
    sbm.state->numberOfDisparities = 112;
    sbm.state->preFilterSize = 5;
    sbm.state->preFilterCap = 61;
    sbm.state->minDisparity = -39;
    sbm.state->textureThreshold = 507;
    sbm.state->uniquenessRatio = 0;
    sbm.state->speckleWindowSize = 0;
    sbm.state->speckleRange = 8;
    sbm.state->disp12MaxDiff = 1;
    
    Mat imgDisparity16S = Mat(leftImage.rows, leftImage.cols, CV_16S);
    Mat imgDisparity8U  = Mat(leftImage.rows, leftImage.cols, CV_8UC1);
    
    sbm(leftImage, rightImage, imgDisparity16S);
    normalize(imgDisparity16S, imgDisparity8U, 0, 255, CV_MINMAX, CV_8U);
    
    [self.resultImages addObject:[MWPhoto photoWithImage:MatToUIImage(imgDisparity8U)]];
}

- (void)computeDepthMapOpticalFlow
{
    cv::cvtColor(leftImage, leftImage, CV_BGR2GRAY);
    cv::cvtColor(rightImage, rightImage, CV_BGR2GRAY);
    
    Mat flow;
    
    calcOpticalFlowFarneback(leftImage, rightImage, flow, 0.5, 3, 15, 3, 5, 1.2, 0 );
    
    NSLog(@"Left image rows: %d cols: %d", leftImage.rows, leftImage.cols);
    NSLog(@"Flow: %d cols: %d", flow.rows, flow.cols);
    
    // Draw optical flow
    Scalar color = Scalar(255);
    Mat arrowResultImage = Mat(rightImage);
    
    for (int y = 0; y < flow.rows; y += 20)
    {
        for (int x = 0; x < flow.cols; x += 20)
        {
            Point2f point = flow.at<Point2f>(y, x);
            
            arrowedLine(arrowResultImage,
                        Point2f(x, y),
                        Point2f((int)(x + point.x), (int)(y + point.y)),
                        color);
        }
    }
    
    [self.resultImages addObject:[MWPhoto photoWithImage:MatToUIImage(arrowResultImage)]];
    
    // Separate flow mat. Preparing for cartToPolar
    vector<Mat> flowPlanes;
    split(flow, flowPlanes);
    
    NSLog(@"flowPlanes[0]: %d cols: %d", flowPlanes[0].rows, flowPlanes[0].cols);
    NSLog(@"flowPlanes[1]: %d cols: %d", flowPlanes[1].rows, flowPlanes[1].cols);
    
    Mat magnitudes;
    Mat angles;
    
    Mat resultImage = Mat(leftImage.rows, leftImage.cols, CV_8UC1);
    cartToPolar(flowPlanes[0], flowPlanes[1], magnitudes, angles);
    
    NSLog(@"Magnitudes: %d cols: %d", magnitudes.rows, magnitudes.cols);
    
    int f = 300;
    int B = 1;
    int W = magnitudes.cols;
    int H = magnitudes.rows;
    
    Mat edges = [self cannyEdgeDetection: leftImage];
    [self.resultImages addObject:[MWPhoto photoWithImage:MatToUIImage(edges)]];

    self.resultPoints = [NSMutableArray array];
    
    for (int y = 0; y < magnitudes.rows; y++)
    {
        for (int x = 0; x < magnitudes.cols; x++)
        {
            char edge = edges.at<char>(y, x);
            float delta = magnitudes.at<float>(y, x);
            
            if (edge != 0) {
                float Z = (B * f) / delta;
                float X = (Z * (x - W / 2.)) / f;
                float Y = (Z * (y - H / 2.)) / f;
                
                float topBound = 1000.0;
                
                if (X < topBound && Y < topBound && Z < topBound)
                {
                    [self.resultPoints addObject:@(X)];
                    [self.resultPoints addObject:@(Y)];
                    [self.resultPoints addObject:@(Z)];
                }
                
                //MyLog(@"v %.6f %.6f %.6f", X, Y, Z);
            }
        }
    }
    
    normalize(magnitudes, resultImage, 0, 255, CV_MINMAX, CV_8U);
    
    [self.resultImages addObject:[MWPhoto photoWithImage:MatToUIImage(resultImage)]];
}

- (void)computeDepthMapOpticalFlowWithImages
{
    UIImage *firstImage = [UIImage imageNamed:@"test_1"];
    UIImage *secondImage = [UIImage imageNamed:@"test_2"];
    
    [self.resultImages addObject:[MWPhoto photoWithImage:firstImage]];
    [self.resultImages addObject:[MWPhoto photoWithImage:secondImage]];
    
    NSLog(@"%f %f", firstImage.size.width, firstImage.size.height);
    
    UIImageToMat(firstImage, leftImage);
    UIImageToMat(secondImage, rightImage);
    
    [self computeDepthMapOpticalFlow];
    [self computeDepthMapStereoBM];
}

#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return self.resultImages.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < self.resultImages.count) {
        return [self.resultImages objectAtIndex:index];
    }
    return nil;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index {
    if (index < self.resultImages.count) {
        return [self.resultImages objectAtIndex:index];
    }
    return nil;
}

#pragma mark - Helpers

- (cv::Mat)cannyEdgeDetection: (cv::Mat&)image
{
    int thresh = 500;
    
    cv::Mat edges;
    cv::Canny(image, edges, thresh, thresh * 3, 5);
    
    return edges;
}

void MyLog(NSString *format, ...)
{
    va_list args;
    va_start(args, format);
    NSString *formattedString = [[NSString alloc] initWithFormat: format
                                                       arguments: args];
    NSString *finalString = [NSString stringWithFormat:@"%@\n",formattedString];
    
    va_end(args);
    [[NSFileHandle fileHandleWithStandardOutput] writeData: [finalString dataUsingEncoding: NSNEXTSTEPStringEncoding]];
}

@end
