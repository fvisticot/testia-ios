//
//  OCRMSAPIManager.m
//  core
//
//  Created by frederic Visticot on 17/09/2017.
//  Copyright © 2017 fvisticot. All rights reserved.
//

#import "OCRMSAPIManager.h"
#import <AFNetworking/AFNetworking.h>


#define API_GATE    @"https://westeurope.api.cognitive.microsoft.com/vision/v1.0"
#define SUBSCRIPTION_KEY @"06f1d70bedbd41a2a904aa912187a627"


@interface OCRMSAPIManager ()
@property(nonatomic,strong) AFHTTPSessionManager *manager;
@end

@implementation OCRMSAPIManager

+ (id)shared {
    static OCRMSAPIManager *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[self alloc] init];
    });
    return shared;
}

- (id)init {
    if (self = [super init]) {
        _manager = [[AFHTTPSessionManager manager] initWithBaseURL:[NSURL URLWithString: API_GATE]];
        _manager.requestSerializer= [AFJSONRequestSerializer serializer];
        [_manager.requestSerializer setValue:SUBSCRIPTION_KEY forHTTPHeaderField:@"Ocp-Apim-Subscription-Key"];
        [_manager.requestSerializer setTimeoutInterval:10.0];
        [_manager.responseSerializer setAcceptableContentTypes: [NSSet setWithObjects:
                                                                 @"application/json", nil]];
        
    }
    return self;
}

-(void)processImage:(id)image withCompletionBlock:(OCRMSAPIManagerCompletionBlock)completionBlock
{
    NSData *imageData = UIImageJPEGRepresentation(image, 0.8);
    NSError *error;
    NSString *urlStr = [NSString stringWithFormat:@"%@/ocr?language=fr", API_GATE];
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"POST" URLString:urlStr parameters:nil error:&error];
    [request setValue:SUBSCRIPTION_KEY forHTTPHeaderField:@"Ocp-Apim-Subscription-Key"];
    [request setValue:@"application/octet-stream" forHTTPHeaderField:@"Content-Type"];
    
    NSURLSessionUploadTask *uploadTask = [_manager uploadTaskWithRequest:request fromData:imageData progress:^(NSProgress * _Nonnull uploadProgress) {
        ;
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (!error)
        {
            completionBlock(self, responseObject, nil);
        } else
        {
            completionBlock(self, nil, error);
        }
    }];
    
    [uploadTask resume];
}

@end
