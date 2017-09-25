//
//  EmotionMSAPIManager.m
//  testia
//
//  Created by frederic Visticot on 15/09/2017.
//  Copyright © 2017 fvisticot. All rights reserved.
//

#import "EmotionMSAPIManager.h"
#import <AFNetworking/AFNetworking.h>
#import "ImageDescription.h"
//https://westus.dev.cognitive.microsoft.com/docs/services/563879b61984550e40cbbe8d/operations/563879b61984550f30395236

#define API_GATE    @"https://westus.api.cognitive.microsoft.com/emotion/v1.0"
#define SUBSCRIPTION_KEY @"9f29c7a05e7644a48c3c7dab79be744c"

@interface EmotionMSAPIManager ()
@property(nonatomic,strong) AFHTTPSessionManager *manager;
@end

@implementation EmotionMSAPIManager

+ (id)shared {
    static EmotionMSAPIManager *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[self alloc] init];
    });
    return shared;
}

- (id)init {
    if (self = [super init]) {
        //_manager = [[AFHTTPSessionManager manager] initWithBaseURL:[NSURL URLWithString: API_GATE]];
        
        _manager = [[AFHTTPSessionManager manager] init];
        //_manager.requestSerializer= [AFJSONRequestSerializer serializer];
        //[_manager.requestSerializer setValue:SUBSCRIPTION_KEY forHTTPHeaderField:@"Ocp-Apim-Subscription-Key"];
        //[_manager.requestSerializer setValue:APP_KEY forHTTPHeaderField:@"app_key"];
        [_manager.requestSerializer setTimeoutInterval:10.0];
        //[_manager.responseSerializer setAcceptableContentTypes: [NSSet setWithObjects:
                                                                 //@"application/octet-stream", nil]];
        
    }
    return self;
}

-(void)enrollWithImage: (ImageDescription*)image inGallery: (NSString*)gallery withCompletionBlock: (EmotionMSAPIManagerCompletionBlock)completionBlock
{
    //NSData *imageData = UIImagePNGRepresentation(image.image);
    NSData *imageData = UIImageJPEGRepresentation(image.image, 0.8);
    NSError *error;
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"POST" URLString:@"https://westus.api.cognitive.microsoft.com/emotion/v1.0/recognize" parameters:nil error:&error];
    [request setValue:SUBSCRIPTION_KEY forHTTPHeaderField:@"Ocp-Apim-Subscription-Key"];
    [request setValue:@"application/octet-stream" forHTTPHeaderField:@"Content-Type"];
    
    NSURLSessionUploadTask *uploadTask = [_manager uploadTaskWithRequest:request fromData:imageData progress:^(NSProgress * _Nonnull uploadProgress) {
        ;
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        ;
    }];
    
    [uploadTask resume];
}


@end
