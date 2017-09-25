//
//  FaceRecognitionKairosAPIManager.h
//  testia
//
//  Created by frederic Visticot on 27/08/2017.
//  Copyright © 2017 fvisticot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImageDescription.h"


@class FaceRecognitionKairosAPIManager;
typedef void(^FaceRecognitionKairosAPIManagerCompletionBlock)(FaceRecognitionKairosAPIManager *service, id object, NSError *error);

@interface FaceRecognitionKairosAPIManager : NSObject
+(id)shared;

-(void)enrollWithImage: (ImageDescription*)image inGallery: (NSString*)gallery withCompletionBlock: (FaceRecognitionKairosAPIManagerCompletionBlock)completionBlock;


@end
