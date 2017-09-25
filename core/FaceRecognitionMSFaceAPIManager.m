//
//  FaceRecognitionMSFaceAPIManager.m
//  testia
//
//  Created by frederic Visticot on 14/09/2017.
//  Copyright © 2017 fvisticot. All rights reserved.
//

#import "FaceRecognitionMSFaceAPIManager.h"
#import <AFNetworking/AFNetworking.h>
#import "ImageDescription.h"
#import "PersonGroup.h"
#import "Person.h"

//https://westus.dev.cognitive.microsoft.com/docs/services/563879b61984550e40cbbe8d/operations/563879b61984550f30395236

#define API_GATE    @"https://westeurope.api.cognitive.microsoft.com/face/v1.0"
#define SUBSCRIPTION_KEY @"086b53ea0bb544a89cd558a6902c87e0"
@interface FaceRecognitionMSFaceAPIManager ()
@property(nonatomic,strong) AFHTTPSessionManager *manager;
@end

@implementation FaceRecognitionMSFaceAPIManager

+ (id)shared {
    static FaceRecognitionMSFaceAPIManager *shared = nil;
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

-(void)createPersonWithName: (NSString*)name inGroup: (NSString*)group withCompletionBlock: (FaceRecognitionMSFaceAPIManagerCompletionBlock)completionBlock
{
    NSString *urlStr = [NSString stringWithFormat: @"persongroups/%@/persons", group];
    NSDictionary *parameters = @{@"name": name};
    
    [_manager POST:urlStr parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        ;
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"Success");
        completionBlock(self, nil, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Error: %@",error.localizedDescription);
        completionBlock(self, nil, error);
    }];
}

-(void)deletePersonWithId: (NSString*)personId inGroupId: (NSString*)groupId withCompletionBlock: (FaceRecognitionMSFaceAPIManagerCompletionBlock)completionBlock
{
    NSString *urlStr = [NSString stringWithFormat: @"persongroups/%@/persons/%@", groupId, personId];
    
    [_manager DELETE:urlStr parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"Success");
        completionBlock(self, nil, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Error: %@",error.localizedDescription);
        completionBlock(self, nil, error);
    }];
}

-(void)imageFaceFromPersonGroup: (NSString*)personGroupId person: (NSString*)personId andFace: (NSString*)faceId withCompletionBlock: (FaceRecognitionMSFaceAPIManagerCompletionBlock)completionBlock
{
    NSString *urlStr = [NSString stringWithFormat: @"persongroups/%@/persons/%@/persistedFaces/%@", personGroupId, personId, faceId];
    [_manager GET:urlStr parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        ;
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completionBlock(self, responseObject, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completionBlock(self, nil, error);
    }];
}


-(void)deleteFaceFromPersonId: (NSString*)personId inGroup: (NSString*)groupId andFaceId: (NSString*)faceId withCompletionBlock: (FaceRecognitionMSFaceAPIManagerCompletionBlock)completionBlock
{
    NSString *urlStr = [NSString stringWithFormat: @"persongroups/%@/persons/%@/persistedFaces/%@", groupId,personId, faceId];
    [_manager DELETE:urlStr parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completionBlock(self, nil, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completionBlock(self, nil, error);
    }];
}

-(void)addImageFace: (ImageDescription*)image fromPersonId: (NSString*)personId inGroup: (NSString*)group progress:(void (^)(NSProgress *uploadProgress)) uploadProgressBlock withCompletionBlock: (FaceRecognitionMSFaceAPIManagerCompletionBlock)completionBlock
{
    NSString *urlStr = [NSString stringWithFormat: @"%@/persongroups/%@/persons/%@/persistedFaces?userData=%@", API_GATE, group,personId, image.userData];
    
    NSData *imageData = UIImageJPEGRepresentation(image.image, 0.8);
    NSError *error;
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"POST" URLString:urlStr parameters:nil error:&error];
    [request setValue:SUBSCRIPTION_KEY forHTTPHeaderField:@"Ocp-Apim-Subscription-Key"];
    [request setValue:@"application/octet-stream" forHTTPHeaderField:@"Content-Type"];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager] init];
                
    NSURLSessionUploadTask *uploadTask = [manager uploadTaskWithRequest:request fromData:imageData progress:^(NSProgress * _Nonnull uploadProgress) {
        uploadProgressBlock(uploadProgress);
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (error)
        {
            NSLog(@"Error: %@", error.localizedDescription);
            completionBlock(self, nil,error);
        }else{
            NSLog(@"Success");
            completionBlock(self, nil, nil);
        }
    }];
    
    [uploadTask resume];
}

-(void)personsFromGroup: (NSString*)group withCompletionBlock: (FaceRecognitionMSFaceAPIManagerCompletionBlock)completionBlock
{
    NSString *urlStr = [NSString stringWithFormat: @"persongroups/%@/persons", group];
    [_manager GET:urlStr parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        ;
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSMutableArray *persons = [NSMutableArray array];
        if (responseObject)
        {
            for (NSDictionary *dic in responseObject)
            {
                Person *person = [[Person alloc] init];
                person.name = dic[@"name"];
                person.personId=dic[@"personId"];
                person.persistedFaceIds=dic[@"persistedFaceIds"];
                [persons addObject: person];
            }
        }
        completionBlock(self, persons, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Error: %@", error.localizedDescription);
        completionBlock(self, nil, error);
    }];
}

-(void)trainPersonGroup: (NSString*)group withCompletionBlock: (FaceRecognitionMSFaceAPIManagerCompletionBlock)completionBlock
{
    NSString *urlStr = [NSString stringWithFormat: @"persongroups/%@/train", group];
    [_manager POST:urlStr parameters:nil progress:^(NSProgress * _Nonnull uploadProgress) {
        ;
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"Success");
        completionBlock(self, nil, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Error: %@", error.localizedDescription);
        completionBlock(self, nil, error);
    }];
}

-(void)personFromId: (NSString*)personId andGroupId: (NSString*)groupId withCompletionBlock: (FaceRecognitionMSFaceAPIManagerCompletionBlock)completionBlock
{
    NSString *urlStr = [NSString stringWithFormat: @"persongroups/%@/persons/%@", groupId, personId];
    [_manager GET:urlStr parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        ;
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        Person *person = [[Person alloc] init];
        person.name = responseObject[@"name"];
        person.personId=responseObject[@"personId"];
        person.persistedFaceIds=responseObject[@"persistedFaceIds"];
        completionBlock(self, person, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completionBlock(self, nil, error);
    }];
}

-(void)personGroupTrainStatus: (NSString*)group withCompletionBlock: (FaceRecognitionMSFaceAPIManagerCompletionBlock)completionBlock
{
    NSString *urlStr = [NSString stringWithFormat: @"persongroups/%@/training", group];
    [_manager GET:urlStr parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        ;
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"Success: %@",responseObject[@"status"]);
        completionBlock(self, responseObject[@"status"], nil);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Error: %@", error.localizedDescription);
        completionBlock(self, nil, error);
    }];
}


-(void)personGroupsWithCompletionBlock: (FaceRecognitionMSFaceAPIManagerCompletionBlock)completionBlock
{
    NSString *urlStr = [NSString stringWithFormat: @"persongroups"];
    [_manager GET:urlStr parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        ;
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSMutableArray *groups = [NSMutableArray array];
        if (responseObject)
        {
            for (NSDictionary *dic in responseObject)
            {
                PersonGroup *personGroup = [[PersonGroup alloc] init];
                personGroup.name = dic[@"name"];
                personGroup.personGroupId=dic[@"personGroupId"];
                [groups addObject: personGroup];
            }
        }
        completionBlock(self, groups, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completionBlock(self, nil, error);
    }];
}

-(void)createPersonGroupWithName: (NSString*)name withCompletionBlock: (FaceRecognitionMSFaceAPIManagerCompletionBlock)completionBlock
{
    NSString *urlStr = [NSString stringWithFormat: @"persongroups/%@", name ];
    NSDictionary *parameters = @{@"name": name};
    
    [_manager PUT:urlStr parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"Success");
        completionBlock(self, nil, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Error: %@",error.localizedDescription);
        completionBlock(self, nil, error);
    }];
}



-(void)deletePersonGroupWithId: (NSString*)personGroupId withCompletionBlock: (FaceRecognitionMSFaceAPIManagerCompletionBlock)completionBlock
{
    NSString *urlStr = [NSString stringWithFormat: @"persongroups/%@", personGroupId];
    
    [_manager DELETE:urlStr parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"Success");
        completionBlock(self, nil, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Error: %@",error.localizedDescription);
        completionBlock(self, nil, error);
    }];
}

-(void)createFaceListWithName: (NSString*)name withCompletionBlock: (FaceRecognitionMSFaceAPIManagerCompletionBlock)completionBlock
{
    NSString *urlStr = [NSString stringWithFormat: @"facelists/%@", name ];
    NSDictionary *parameters = @{@"name": name};
    
    [_manager PUT:urlStr parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"Success");
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Error: %@",error.localizedDescription);
        
    }];
}

-(void)addImageFace: (ImageDescription*)image inFaceList: (NSString*)faceList withCompletionBlock: (FaceRecognitionMSFaceAPIManagerCompletionBlock)completionBlock
{
    NSString *urlStr = [NSString stringWithFormat: @"%@/facelists/%@/persistedFaces", API_GATE,faceList];
    
    NSData *imageData = UIImageJPEGRepresentation(image.image, 0.8);
    NSError *error;
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"POST" URLString:urlStr parameters:nil error:&error];
    [request setValue:SUBSCRIPTION_KEY forHTTPHeaderField:@"Ocp-Apim-Subscription-Key"];
    [request setValue:@"application/octet-stream" forHTTPHeaderField:@"Content-Type"];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager] init];
    
    NSURLSessionUploadTask *uploadTask = [manager uploadTaskWithRequest:request fromData:imageData progress:^(NSProgress * _Nonnull uploadProgress) {
        ;
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (error)
        {
            NSLog(@"Error: %@", error.localizedDescription);
        }else{
            NSLog(@"Success");//c843efe2-7bcc-4be2-adfe-3e4436482e54
        }
    }];
    
    [uploadTask resume];
}

-(void)faceDetect: (UIImage*)image progress:(void (^)(NSProgress *uploadProgress))uploadProgressBlock withCompletionBlock: (FaceRecognitionMSFaceAPIManagerCompletionBlock)completionBlock
{
    NSString *urlStr = [NSString stringWithFormat: @"%@/detect", API_GATE];
    
    NSData *imageData = UIImageJPEGRepresentation(image, 0.8);
    NSError *error;
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"POST" URLString:urlStr parameters:nil error:&error];
    [request setValue:SUBSCRIPTION_KEY forHTTPHeaderField:@"Ocp-Apim-Subscription-Key"];
    [request setValue:@"application/octet-stream" forHTTPHeaderField:@"Content-Type"];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager] init];
    
    NSURLSessionUploadTask *uploadTask = [manager uploadTaskWithRequest:request fromData:imageData progress:^(NSProgress * _Nonnull uploadProgress) {
        uploadProgressBlock(uploadProgress);
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (error)
        {
            NSLog(@"Error: %@", error.localizedDescription);
            completionBlock(self, nil, error);
        }else{
            NSLog(@"Success: %@", [responseObject lastObject][@"faceId"]);//c843efe2-7bcc-4be2-adfe-3e4436482e54
            completionBlock(self, responseObject, nil);
        }
    }];
    
    [uploadTask resume];
}

-(void)identifyFaces: (NSArray*)faces fromGroup: (NSString*)group withCompletionBlock: (FaceRecognitionMSFaceAPIManagerCompletionBlock)completionBlock
{
    NSString *urlStr = [NSString stringWithFormat: @"identify"];
    NSDictionary *parameters = @{
                                 @"faceIds": faces,
                                 @"personGroupId": group
                                 };
    [_manager POST:urlStr parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        ;
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"Success");
        completionBlock(self, responseObject, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Error: %@", error.localizedDescription);
        NSData *data= error.userInfo[@"com.alamofire.serialization.response.error.data"];
        NSLog(@"%@", [[NSString alloc] initWithData:data encoding: NSUTF8StringEncoding]);
        completionBlock(self, nil, error);
    }];
}


@end
