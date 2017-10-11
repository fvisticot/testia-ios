//
//  EmotionViewController.m
//  testia
//
//  Created by frederic Visticot on 10/10/2017.
//  Copyright © 2017 fvisticot. All rights reserved.
//

#import "EmotionViewController.h"
#import "UINavigationController+M13ProgressViewBar.h"
#import "EmotionMSAPIManager.h"
#import "UtilHelper.h"

@import AVFoundation;

@interface EmotionViewController ()<AVCapturePhotoCaptureDelegate, AVCaptureVideoDataOutputSampleBufferDelegate>
@property(nonatomic, strong) AVCapturePhotoSettings * captureSettings;
@property(nonatomic, strong) AVCaptureSession *captureSession;
@property(nonatomic, strong) AVCapturePhotoOutput *captureOutput;
@property(nonatomic, strong) AVCaptureVideoDataOutput *captureVideoOutput;
@property(nonatomic, strong) AVCaptureDevice *selectedDevice;
@end

@implementation EmotionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title=@"Emotion";
    
    UIBarButtonItem *addButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionMenu:)];
    self.navigationItem.rightBarButtonItem=addButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)actionMenu: (id)sender
{
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"Actions" message:@"Available actions" preferredStyle:UIAlertControllerStyleActionSheet];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
        // Cancel button tappped.
        [self dismissViewControllerAnimated:YES completion:^{
        }];
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Analyse emotion (library)" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self analyseFromLibrary];
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Analyse emotion (camera)" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self analyseFromCamera];
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Analyse emotion (live)" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self analyseFromLiveCamera];
    }]];
    
    // Present action sheet.
    [self presentViewController:actionSheet animated:YES completion:nil];
}

-(void)analyseFromLibrary
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:picker animated:YES completion:NULL];
}

-(void)analyseFromCamera
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:picker animated:YES completion:NULL];
}

-(void)analyseFromLiveCamera {
    _captureSession = [[AVCaptureSession alloc] init];
    if ([_captureSession canSetSessionPreset:AVCaptureSessionPreset640x480]) {
        _captureSession.sessionPreset = AVCaptureSessionPreset640x480;
    }
    else {
        NSLog(@"No session preset");
    }
    NSArray * deviceTypes = @[AVCaptureDeviceTypeBuiltInWideAngleCamera, AVCaptureDeviceTypeBuiltInDuoCamera, AVCaptureDeviceTypeBuiltInTelephotoCamera];
    NSArray *devices = [[AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:deviceTypes mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionUnspecified] devices];
    
    for (AVCaptureDevice *device in devices) {
        
        NSLog(@"Device name: %@", [device localizedName]);
        
        if ([device hasMediaType:AVMediaTypeVideo]) {
            
            if ([device position] == AVCaptureDevicePositionBack) {
                NSLog(@"Device position : back");
            }
            else {
                NSLog(@"Device position : front");
                _selectedDevice = device;
            }
        }
    }
    
    NSArray *supportedFrameRateRanges = [_selectedDevice.activeFormat videoSupportedFrameRateRanges];
    
    for (AVFrameRateRange *range in supportedFrameRateRanges) {
        NSLog(@"%@", range);
        NSLog(@"");
    }
    
    NSError *error;
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:_selectedDevice error:&error];
    if (!deviceInput) {
        NSLog(@"Error: %@", error.localizedDescription);
    }
    
    if ([_captureSession canAddInput:deviceInput]) {
        [_captureSession addInput:deviceInput];
    }
    else {
        NSLog(@"Can not addInput");
    }

    //Preview Layer
    AVCaptureVideoPreviewLayer *previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
    previewLayer.frame = _cameraPreview.bounds;
    previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [_cameraPreview.layer addSublayer:previewLayer];
    
    [_captureSession startRunning];
}

//https://www.objc.io/issues/23-video/capturing-video/
- (IBAction)captureButtonClicked:(id)sender {
    if (_captureOutput == nil) {
        _captureOutput = [[AVCapturePhotoOutput alloc] init];
        if ([_captureSession canAddOutput:_captureOutput]) {
            [_captureSession addOutput:_captureOutput];
        }
        else {
            NSLog(@"Can not addOutput");
        }
    }
    AVCapturePhotoSettings *captureSettings = [AVCapturePhotoSettings photoSettings];
    [_captureOutput capturePhotoWithSettings: captureSettings delegate:self];
}

- (IBAction)captureVideoButtonClicked:(id)sender {
    NSError *error;
    CMTime frameDuration = CMTimeMake(1, 2);
    if ([_selectedDevice lockForConfiguration:&error]) {
        [_selectedDevice setActiveVideoMaxFrameDuration:frameDuration];
        [_selectedDevice setActiveVideoMinFrameDuration:frameDuration];
        [_selectedDevice unlockForConfiguration];
    }
    
    if (_captureVideoOutput == nil) {
        _captureVideoOutput = [[AVCaptureVideoDataOutput alloc] init];
        [_captureVideoOutput recommendedVideoSettingsForAssetWriterWithOutputFileType: AVFileTypeMPEG4];
        [_captureVideoOutput setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA] forKey:(NSString*)kCVPixelBufferPixelFormatTypeKey]];
        dispatch_queue_t videoDataOutputQueue = dispatch_queue_create("VideoDataOutputQueue", DISPATCH_QUEUE_SERIAL);
        [_captureVideoOutput setSampleBufferDelegate: self queue: videoDataOutputQueue];
        if ([_captureSession canAddOutput:_captureVideoOutput]) {
            [_captureSession addOutput:_captureVideoOutput];
        }
        else {
            NSLog(@"Can not addOutput");
        }
    }
    
    //AVCapturePhotoSettings *captureSettings = [AVCapturePhotoSettings photoSettings];
    //[_captureVideoOutput capturePhotoWithSettings: captureSettings delegate:self];
}


-(void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    NSLog(@"--->video output");
    UIImage *image = [self imageFromSampleBuffer2:sampleBuffer];
    [self processImage: image];
}

- (UIImage *) imageFromSampleBuffer2:(CMSampleBufferRef) sampleBuffer
{
    // Get a CMSampleBuffer's Core Video image buffer for the media data
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    
    // Lock the base address of the pixel buffer
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    // Get the number of bytes per row for the pixel buffer
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    
    // Get the number of bytes per row for the pixel buffer
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    
    // Get the pixel buffer width and height
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    NSLog(@"w: %zu h: %zu bytesPerRow:%zu", width, height, bytesPerRow);
    
    // Create a device-dependent RGB color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // Create a bitmap graphics context with the sample buffer data
    CGContextRef context = CGBitmapContextCreate(baseAddress,
                                                 width,
                                                 height,
                                                 8,
                                                 bytesPerRow,
                                                 colorSpace,
                                                 kCGBitmapByteOrder32Little
                                                 | kCGImageAlphaPremultipliedFirst);
    // Create a Quartz image from the pixel data in the bitmap graphics context
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    // Unlock the pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
    // Free up the context and color space
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    // Create an image object from the Quartz image
    //UIImage *image = [UIImage imageWithCGImage:quartzImage];
    UIImage *image = [UIImage imageWithCGImage:quartzImage
                                         scale:1.0f
                                   orientation:UIImageOrientationRight];
    
    // Release the Quartz image
    CGImageRelease(quartzImage);
    
    return (image);
}

- (CGImageRef) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer // Create a CGImageRef from sample buffer data
{
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer,0);        // Lock the image buffer
    
    uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0);   // Get information of the image
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef newContext = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGImageRef newImage = CGBitmapContextCreateImage(newContext);
    CGContextRelease(newContext);
    
    CGColorSpaceRelease(colorSpace);
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    /* CVBufferRelease(imageBuffer); */  // do not call this!
    
    return newImage;
}

-(void)captureOutput:(AVCapturePhotoOutput *)output didFinishProcessingPhoto:(AVCapturePhoto *)photo error:(NSError *)error {
    NSData *imageData = [photo fileDataRepresentation];
    UIImage *image = [UIImage imageWithData: imageData];
    [self processImage: image];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *image = info[UIImagePickerControllerEditedImage];
    
    [self processImage: image];
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

-(void)processImage: (UIImage*)image {
    [self.navigationController showProgress];
    
    [[EmotionMSAPIManager shared] analyseEmotionFromImage: image progress:^(NSProgress *uploadProgress) {
        [self.navigationController setProgress:uploadProgress.fractionCompleted animated: YES];
    }  withCompletionBlock:^(EmotionMSAPIManager *service, id object, NSError *error) {
        [self.navigationController finishProgress];
        if (!error) {
            NSArray *res = (NSArray*)object;
            if (res.count == 0) {
                return;
            }
            
            for (NSDictionary *dic in res) {
                NSDictionary *score = dic[@"scores"];
                for (NSString *key in [score allKeys]) {
                    double value = [score[key] doubleValue];
                    if (value > 0.3) {
                        NSLog(@"%@ %1.1f", key, value);
                        _emotionLabel.text = [NSString stringWithFormat:@"%@ %1.1f", key, value];
                    }
                }
            }
            
        } else {
            [UtilHelper dialogWithMSError: error inViewController:self];
        }
    }];
    
    [self.navigationController showProgress];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/



@end
