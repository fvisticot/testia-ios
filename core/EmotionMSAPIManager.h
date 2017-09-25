//
//  EmotionMSAPIManager.h
//  testia
//
//  Created by frederic Visticot on 15/09/2017.
//  Copyright © 2017 fvisticot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImageDescription.h"

@class EmotionMSAPIManager;
typedef void(^EmotionMSAPIManagerCompletionBlock)(EmotionMSAPIManager *service, id object, NSError *error);

@interface EmotionMSAPIManager : NSObject
+(id)shared;
-(void)enrollWithImage: (ImageDescription*)image inGallery: (NSString*)gallery withCompletionBlock: (EmotionMSAPIManagerCompletionBlock)completionBlock;


@end
