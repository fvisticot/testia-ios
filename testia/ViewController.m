//
//  ViewController.m
//  testia
//
//  Created by frederic Visticot on 28/06/2017.
//  Copyright © 2017 fvisticot. All rights reserved.
//

#import "ViewController.h"
//#import "GoogLeNetPlaces.h"
//#import "MNISTClassifier.h"
#import <OpenCV/opencv2/opencv.hpp>
#import <OpenCV/opencv2/imgcodecs/ios.h>

#import <CoreML/CoreML.h>
#import <Vision/Vision.h>
#import <CoreImage/CoreImage.h>

//#import <AVFoundation/AVFoundation.h>
//#import <CoreMedia/CoreMedia.h>

/*namespace cv
{
    using std::vector;
}
*/

using namespace cv;
using namespace std;

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //[self testOpenCVGrayImage];
    [self testOpenCVHough];
    //[self testTextRectangles];
    //[self testFacesRectangles];
    //[self testRectangles];
}

-(void)testCoreML
{
    MLModel *model = nil;//[[[GoogLeNetPlaces alloc] init] model];
    NSError *error;
    VNCoreMLModel *mlModel = [VNCoreMLModel modelForMLModel: model error: &error];
    VNCoreMLRequest *mlRequest = [[VNCoreMLRequest alloc] initWithModel: mlModel];
    
    UIImage *image = [UIImage imageNamed: @"car"];
    NSData *data = UIImagePNGRepresentation(image);
    NSDictionary *dic;
    VNImageRequestHandler *handler = [[VNImageRequestHandler alloc] initWithData:data options: dic];
    NSError *errorReq;
    [handler performRequests: @[mlRequest] error: &errorReq];
    
    
    
    NSArray<VNClassificationObservation*>* results = [mlRequest results];
    for (VNClassificationObservation *observation in results)
    {
        if (observation.confidence > 0.1)
        {
        NSLog(@"Feature: %@ Confidence: %1.1f",observation.identifier, observation.confidence);
        //VNFaceLandmarks2D *landmarks =  observation.landmarks;
        //NSMutableArray<VNFaceLandmarkRegion2D*> *landmarkRegions = [NSMutableArray array];
        //[landmarkRegions addObject: landmarks.faceContour];
        //VNFaceLandmarkRegion2D *leftEye =  landmarks.leftEye;
        }
        
    }
    //[self drawImageFromSource: image observations:(NSArray *) results andRegions:nil];
    NSLog(@"Error: %@", errorReq);
}

-(void)testMNISTClassifierCoreMLFromImage: (UIImage *)image
{
    MLModel *model = nil;//[[[MNISTClassifier alloc] init] model];
    NSError *error;
    VNCoreMLModel *mlModel = [VNCoreMLModel modelForMLModel: model error: &error];
    VNCoreMLRequest *mlRequest = [[VNCoreMLRequest alloc] initWithModel: mlModel];
    
    NSDictionary *dic;
    VNImageRequestHandler *handler = [[VNImageRequestHandler alloc] initWithCGImage: image.CGImage options: dic];
    //VNImageRequestHandler *handler = [[VNImageRequestHandler alloc] initWithData:data options: dic];
    NSError *errorReq;
    [handler performRequests: @[mlRequest] error: &errorReq];
    
    NSArray<VNClassificationObservation*>* results = [mlRequest results];
    for (VNClassificationObservation *observation in results)
    {
        if (observation.confidence > 0.6)
        {
            NSLog(@"Feature: %@ Confidence: %1.1f",observation.identifier, observation.confidence);
            //VNFaceLandmarks2D *landmarks =  observation.landmarks;
            //NSMutableArray<VNFaceLandmarkRegion2D*> *landmarkRegions = [NSMutableArray array];
            //[landmarkRegions addObject: landmarks.faceContour];
            //VNFaceLandmarkRegion2D *leftEye =  landmarks.leftEye;
        }
        
    }
    //[self drawImageFromSource: image observations:(NSArray *) results andRegions:nil];
    NSLog(@"Error: %@", errorReq);
}

-(void)testRectangles
{
    VNDetectRectanglesRequest *rectanglesRequest = [VNDetectRectanglesRequest new];
    //rectanglesRequest.minimumSize = 0.3;
    
    UIImage *image = [UIImage imageNamed: @"rectangles"];
    _imageView.image=image;
    NSData *data = UIImagePNGRepresentation(image);
    NSDictionary *dic;
    VNImageRequestHandler *handler = [[VNImageRequestHandler alloc] initWithData:data options: dic];
    NSError *errorReq;
    [handler performRequests: @[rectanglesRequest] error: &errorReq];
    
    NSArray<VNRectangleObservation*>* results = [rectanglesRequest results];
    NSMutableArray *boundingBoxes = [NSMutableArray array];
    for (VNRectangleObservation *observation in results)
    {
        NSLog(@"%@ Confidence: %1.1f", NSStringFromCGRect([observation boundingBox]), observation.confidence);
        [boundingBoxes addObject: [NSValue valueWithCGRect: observation.boundingBox]];
        
    }
    UIImage *imageRes=[self overlayImageFromBoundingBoxes: boundingBoxes size: image.size];
    _overlayImageView.image = imageRes;
    NSLog(@"Error: %@", errorReq);
}

-(void)testTextRectangles
{
    VNDetectTextRectanglesRequest *textRectanglesRequest = [VNDetectTextRectanglesRequest new];
    textRectanglesRequest.reportCharacterBoxes=YES;
    
    UIImage *image = [UIImage imageNamed: @"plaque-imat"];
    [_imageView setContentMode: UIViewContentModeScaleAspectFit];
    _imageView.image = image;
    
    NSData *data = UIImagePNGRepresentation(image);
    NSDictionary *dic;
    VNImageRequestHandler *handler = [[VNImageRequestHandler alloc] initWithData:data options: dic];
    NSError *errorReq;
    [handler performRequests: @[textRectanglesRequest] error: &errorReq];
    
    NSArray<VNTextObservation*>* results = [textRectanglesRequest results];
    NSLog(@"%lu results found", (unsigned long)results.count);
    
    NSMutableArray *boundingBoxes = [NSMutableArray array];
    
    UIImage *boundingImage;
    int i=0;
    for (VNTextObservation *observation in results)
    {
        NSArray<VNRectangleObservation *>* rectangeObservations = observation.characterBoxes;
        [boundingBoxes addObject: [NSValue valueWithCGRect: observation.boundingBox]];
        
        for (VNRectangleObservation *rectangleObservation in rectangeObservations)
        {
            //NSLog(@"RectangleObservation: %@", rectangleObservation);
            [boundingBoxes addObject: [NSValue valueWithCGRect: rectangleObservation.boundingBox]];
            //if (i==2)
            {
                boundingImage=[self coreImageTestFromImage: image andRectangeObservation: rectangleObservation];
                [self testMNISTClassifierCoreMLFromImage: boundingImage];
                _workImageView.image=boundingImage;
                //NSLog(@"Image: %@", NSStringFromCGSize(boundingImage.size));
            }
            i++;
            
        }
    }
    UIImage *imageRes=[self overlayImageFromBoundingBoxes: boundingBoxes size: image.size];
    _overlayImageView.image = imageRes;
    
    NSLog(@"Bounding boxes found: %ld", boundingBoxes.count);
}

-(void)testFacesRectangles
{
    VNDetectFaceRectanglesRequest *faceRectanglesRequest = [VNDetectFaceRectanglesRequest new];
    UIImage *image = [UIImage imageNamed: @"faces6"];
    _imageView.image = image;
    
    NSData *data = UIImagePNGRepresentation(image);
    NSDictionary *dic;
    VNImageRequestHandler *handler = [[VNImageRequestHandler alloc] initWithData:data options: dic];
    NSError *errorReq;
    [handler performRequests: @[faceRectanglesRequest] error: &errorReq];
    
    NSArray<VNFaceObservation*>* results = [faceRectanglesRequest results];
    
    NSMutableArray *boundingBoxes = [NSMutableArray array];
    for (VNFaceObservation *observation in results)
    {
        NSLog(@"%@ Confidence: %1.1f", NSStringFromCGRect([observation boundingBox]), observation.confidence);
        VNFaceLandmarks2D *landmarks =  observation.landmarks;
        NSMutableArray<VNFaceLandmarkRegion2D*> *landmarkRegions = [NSMutableArray array];
        [boundingBoxes addObject: [NSValue valueWithCGRect: observation.boundingBox]];
    }
    
    UIImage *imageRes=[self overlayImageFromBoundingBoxes: boundingBoxes size: image.size];
    _overlayImageView.image=imageRes;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (UIImage *)overlayImageWithTextObservations:(NSArray<VNTextObservation *> *)results size:(CGSize)size
{
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:size];
    UIImage *overlayImage = [renderer imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull rendererContext) {
        CGAffineTransform t = CGAffineTransformIdentity;
        t = CGAffineTransformScale(t, size.width, -size.height);
        t = CGAffineTransformTranslate(t, 0, -1);
        for (VNTextObservation *textObservation in results) {
            [[UIColor redColor] setStroke];
            [[UIBezierPath bezierPathWithRect:CGRectApplyAffineTransform(textObservation.boundingBox, t)] stroke];
            for (VNRectangleObservation *rectangleObservation in textObservation.characterBoxes) {
                [[UIColor blueColor] setStroke];
                [[UIBezierPath bezierPathWithRect:CGRectApplyAffineTransform(rectangleObservation.boundingBox, t)] stroke];
            }
        }
    }];
    return overlayImage;
}

- (UIImage *)overlayImageFromBoundingBoxes:(NSArray<NSValue *> *)results size:(CGSize)size
{
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:size];
    UIImage *overlayImage = [renderer imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull rendererContext) {
        CGRect rect = CGRectMake(0, 0, size.width, size.height);
        CGAffineTransform t = CGAffineTransformIdentity;
        t = CGAffineTransformScale(t, rect.size.width, -rect.size.height);
        t = CGAffineTransformTranslate(t, 0, -1);
            for (NSValue *value in results) {
                CGRect boundingBox = [value CGRectValue];
                [[UIColor redColor] setStroke];
                UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRect:CGRectApplyAffineTransform(boundingBox, t)];
                //bezierPath.lineWidth=8.0;
                [bezierPath stroke];
            }
    }];
    return overlayImage;
}

-(UIImage*)coreImageTestFromImage: (UIImage*)image andRectangeObservation: (VNRectangleObservation*)rectangleObservation
{
    CIImage *cimage = [CIImage imageWithData: UIImagePNGRepresentation(image)];
    
    CGRect scaledBoundingBox = [self scaledRect:rectangleObservation.boundingBox toSize: image.size];
    
    CGPoint topLeft = [self scaledPoint:rectangleObservation.topLeft toSize: image.size];
    CGPoint topRight = [self scaledPoint:rectangleObservation.topRight toSize: image.size];
    CGPoint bottomLeft = [self scaledPoint:rectangleObservation.bottomLeft toSize: image.size];
    CGPoint bottomRight = [self scaledPoint:rectangleObservation.bottomRight toSize: image.size];
    
    
    
    CIImage *croppedImage = [cimage imageByCroppingToRect: scaledBoundingBox];
    CIImage *perpectiveImage = [croppedImage  imageByApplyingFilter: @"CIPerspectiveCorrection" withInputParameters:
                                @{@"inputTopLeft": [CIVector vectorWithCGPoint:topLeft],
                                  @"inputTopRight": [CIVector vectorWithCGPoint: topRight],
                                  @"inputBottomLeft": [CIVector vectorWithCGPoint: bottomLeft],
                                  @"inputBottomRight": [CIVector vectorWithCGPoint: bottomRight]
                                  }];
    
    CIImage *colorControlImage=[perpectiveImage imageByApplyingFilter: @"CIColorControls" withInputParameters: @{kCIInputSaturationKey: @0, kCIInputContrastKey: @32}];
    CIImage *colorInvertImage = [colorControlImage imageByApplyingFilter: @"CIColorInvert" withInputParameters: nil];
    UIImage *resultImage = [self makeUIImageFromCIImage: colorInvertImage]; //[UIImage imageWithCIImage: colorInvertImage];
    return resultImage;
}

- (UIImage *)makeUIImageFromCIImage:(CIImage *)ciImage {
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgImage = [context createCGImage:ciImage fromRect:[ciImage extent]];
    
    UIImage* uiImage = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    
    return uiImage;
}

-(CGPoint)scaledPoint: (CGPoint)point toSize: (CGSize)size
{
    return CGPointMake(point.x * size.width, point.y * size.height);
}

-(CGRect)scaledRect: (CGRect)rect toSize: (CGSize)size
{
    float x = rect.origin.x * size.width;
    float y = rect.origin.y * size.height;
    float width = rect.size.width * size.width;
    float height = rect.size.height *size.height;
    
    return CGRectMake(x, y, width, height);
}


-(void)testOpenCVGrayImage
{
    UIImage *imageInput = [UIImage imageNamed: @"car"];
    _imageView.image=imageInput;
    NSLog(@"Size: %@", NSStringFromCGSize(imageInput.size));
    
    cv::Mat originalMat = [self cvMatFromUIImage: imageInput];
    cv::Mat grayMat;
    cv::cvtColor(originalMat, grayMat, CV_BGR2GRAY);
    
    UIImage *grayImage = [self UIImageFromCVMat:grayMat];
    _imageView.image=grayImage;
}

-(void)testOpenCVHough
{
    UIImage *inputImage = [UIImage imageNamed: @"baby-3"];
    _imageView.image=inputImage;
    NSLog(@"Size: %@", NSStringFromCGSize(inputImage.size));
    
    Mat originalMat = [self cvMatFromUIImage: inputImage];
    Mat grayMat;
    cvtColor(originalMat, grayMat, CV_BGR2GRAY);
    UIImage *grayImage = [self UIImageFromCVMat:grayMat];
    //_imageView.image=grayImage;
    
    
    //cv::vector<cv::Vec3f> circles;
    vector<Vec3f> circles;
    cv::HoughCircles(grayMat, circles, CV_HOUGH_GRADIENT, 2, 50.0, 200, 100, 20, 50);
    
    for( size_t i = 0; i < circles.size(); i++ )
    {
        cv::Point center(cvRound(circles[i][0]), cvRound(circles[i][1]));
        int radius = cvRound(circles[i][2]);
        NSLog(@"x:%d, y:%d, radius: %d", center.x, center.y, radius);
        circle(originalMat, center, 3, Scalar(0,255,0), -1, 8, 0 );
        // circle outline
        circle(originalMat, center, radius, Scalar(0,0,255), 3, 8, 0 );
    }
    NSLog(@"Circles: %lu", (unsigned long)circles.size());
    UIImage *resultImage = [self UIImageFromCVMat:originalMat];
    _imageView.image=resultImage;
    
    
}

- (cv::Mat)cvMatFromUIImage:(UIImage*)image
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels (color channels + alpha)
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,     // Pointer to data
                                                    cols,           // Width of bitmap
                                                    rows,           // Height of bitmap
                                                    8,              // Bits per component
                                                    cvMat.step[0],  // Bytes per row
                                                    colorSpace,     // Color space
                                                    kCGImageAlphaNoneSkipLast
                                                    | kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    return cvMat;
}

- (cv::Mat)cvMatGrayFromUIImage:(UIImage *)image
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    cv::Mat cvMat(rows, cols, CV_8UC1); // 8 bits per component, 1 channels
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    return cvMat;
}

- (UIImage *)UIImageFromCVMat:(cv::Mat)cvMat
{
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
    
    CGColorSpaceRef colorspace;
    
    if (cvMat.elemSize() == 1) {
        colorspace = CGColorSpaceCreateDeviceGray();
    }else{
        colorspace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    // Create CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(cvMat.cols, cvMat.rows, 8, 8 * cvMat.elemSize(), cvMat.step[0], colorspace, kCGImageAlphaNone | kCGBitmapByteOrderDefault, provider, NULL, false, kCGRenderingIntentDefault);
    
    // get uiimage from cgimage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorspace);
    return finalImage;
}
@end
