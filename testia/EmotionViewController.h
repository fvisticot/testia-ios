//
//  EmotionViewController.h
//  testia
//
//  Created by frederic Visticot on 10/10/2017.
//  Copyright © 2017 fvisticot. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EmotionViewController : UIViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIView *cameraPreview;
- (IBAction)captureButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *emotionLabel;
- (IBAction)captureVideoButtonClicked:(id)sender;

@end
