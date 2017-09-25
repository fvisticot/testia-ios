//
//  FaceTableViewCell.h
//  testia
//
//  Created by frederic Visticot on 16/09/2017.
//  Copyright © 2017 fvisticot. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FaceTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *faceIdLabel;
@property (weak, nonatomic) IBOutlet UIImageView *faceImageView;

@end
