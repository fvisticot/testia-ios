//
//  FaceRecognitionChuiAPIManager.m
//  testia
//
//  Created by frederic Visticot on 27/08/2017.
//  Copyright © 2017 fvisticot. All rights reserved.
//

#import "FaceRecognitionChuiAPIManager.h"


#import <AFNetworking/AFNetworking.h>


#define API_GATE    @"https://api.chui.ai/v1"
#define APP_KEY     @"W43WVFjKoz3blxiFguydEa6wGx7TjlFOaK3ZDVMS"

@interface FaceRecognitionChuiAPIManager ()
@property(nonatomic,strong) AFHTTPSessionManager *manager;
@end

@implementation FaceRecognitionChuiAPIManager

+ (id)shared {
    static FaceRecognitionChuiAPIManager *shared = nil;
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
        [_manager.requestSerializer setValue:APP_KEY forHTTPHeaderField:@"x-api-key"];
        [_manager.requestSerializer setTimeoutInterval:10.0];
        [_manager.responseSerializer setAcceptableContentTypes: [NSSet setWithObjects: @"application/hal+json",
                                                                 @"application/json", nil]];
        
    }
    return self;
}

-(void)enrollWithImage: (ImageDescription*)image inGallery: (NSString*)gallery withCompletionBlock: (FaceRecognitionChuiAPIManagerCompletionBlock)completionBlock
{
    //NSData *imageData = UIImagePNGRepresentation(image.image);
    NSData *imageData = UIImageJPEGRepresentation(image.image, 0.8);
    //NSString *imageData64 = [imageData base64EncodedStringWithOptions: NSDataBase64Encoding64CharacterLineLength];
    
    NSString *imageData64 = [imageData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    
    NSData *decodedImageData = [[NSData alloc] initWithBase64EncodedData: imageData64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    UIImage *decodedImage = [UIImage imageWithData:decodedImageData];
    
    NSDictionary *parameters = @{
                                 @"img0": imageData64,
                                 @"name": @"fred",
                                 @"collection_id": @"gallery1"
                                 };
    [_manager POST:@"enroll" parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        ;
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"success");
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Error: %@", error.localizedDescription);
    }];
    
    /*[_manager POST:@"enroll" parameters: parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
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
