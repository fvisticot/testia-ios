//
//  FaceRecognitionKairosAPIManager.m
//  testia
//
//  Created by frederic Visticot on 27/08/2017.
//  Copyright © 2017 fvisticot. All rights reserved.
//

#import "FaceRecognitionKairosAPIManager.h"
#import <AFNetworking/AFNetworking.h>


#define API_GATE    @"http://api.kairos.com"
#define APP_ID      @"22e1b9e9"
#define APP_KEY     @"82da03da7978f1c209d89c5efb522704"

@interface FaceRecognitionKairosAPIManager ()
@property(nonatomic,strong) AFHTTPSessionManager *manager;
@end

@implementation FaceRecognitionKairosAPIManager

+ (id)shared {
    static FaceRecognitionKairosAPIManager *shared = nil;
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
        [_manager.requestSerializer setValue:APP_ID forHTTPHeaderField:@"app_id"];
        [_manager.requestSerializer setValue:APP_KEY forHTTPHeaderField:@"app_key"];
        [_manager.requestSerializer setTimeoutInterval:10.0];
        [_manager.responseSerializer setAcceptableContentTypes: [NSSet setWithObjects: @"application/hal+json",
                                                                 @"application/json", nil]];
        
    }
    return self;
}

-(void)enrollWithImage: (ImageDescription*)image inGallery: (NSString*)gallery withCompletionBlock: (FaceRecognitionKairosAPIManagerCompletionBlock)completionBlock
{
    //NSData *imageData = UIImagePNGRepresentation(image.image);
    NSData *imageData = UIImageJPEGRepresentation(image.image, 0.8);
    
    NSString *imageData64 = [imageData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    NSDictionary *parameters = @{
                                 @"image": imageData64,
                                 @"subject_id": @"fred",
                                 @"gallery_name": @"gallery1"
                                 };
    [_manager POST:@"enroll" parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        ;
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"success");
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Error: %@", error.localizedDescription);
    }];
    
    
    /*
    [_manager POST:@"enroll" parameters: parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [formData appendPartWithFileData: imageData name:@"image" fileName:@"fred1.png" mimeType:@"application/octet-stream"];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        ;
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"success");
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Error: %@", error.localizedDescription);
    }];
    */
}


@end
