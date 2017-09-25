//
//  FaceRecognitionChuiAPIManager.h
//  testia
//
//  Created by frederic Visticot on 27/08/2017.
//  Copyright © 2017 fvisticot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImageDescription.h"

@class FaceRecognitionChuiAPIManager;
typedef void(^FaceRecognitionChuiAPIManagerCompletionBlock)(FaceRecognitionChuiAPIManager *service, id object, NSError *error);

@interface FaceRecognitionChuiAPIManager : NSObject

+(id)shared;

-(void)enrollWithImage: (ImageDescription*)image inGallery: (NSString*)gallery withCompletionBlock: (FaceRecognitionChuiAPIManagerCompletionBlock)completionBlock;

@end
