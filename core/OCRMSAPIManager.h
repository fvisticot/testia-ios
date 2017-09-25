//
//  OCRMSAPIManager.h
//  core
//
//  Created by frederic Visticot on 17/09/2017.
//  Copyright © 2017 fvisticot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class OCRMSAPIManager;
typedef void(^OCRMSAPIManagerCompletionBlock)(OCRMSAPIManager *service, id object, NSError *error);

@interface OCRMSAPIManager : NSObject
+(id)shared;
-(void)processImage: (UIImage*)image withCompletionBlock: (OCRMSAPIManagerCompletionBlock)completionBlock;


@end
