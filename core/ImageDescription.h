//
//  ImageDescription.h
//  testia
//
//  Created by frederic Visticot on 27/08/2017.
//  Copyright © 2017 fvisticot. All rights reserved.
//

#import <Foundation/Foundation.h>

@import UIKit;

@interface ImageDescription : NSObject
@property(nonatomic, strong) UIImage *image;
@property(nonatomic, strong) NSString *name;
@property(nonatomic, strong) NSString *userData;
@end
