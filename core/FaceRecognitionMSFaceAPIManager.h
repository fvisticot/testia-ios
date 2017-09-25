//
//  FaceRecognitionMSFaceAPIManager.h
//  testia
//
//  Created by frederic Visticot on 14/09/2017.
//  Copyright © 2017 fvisticot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImageDescription.h"

@interface FaceRecognitionMSFaceAPIManager : NSObject
typedef void(^FaceRecognitionMSFaceAPIManagerCompletionBlock)(FaceRecognitionMSFaceAPIManager *service, id object, NSError *error);

+(id)shared;

-(void)personGroupsWithCompletionBlock: (FaceRecognitionMSFaceAPIManagerCompletionBlock)completionBlock;
-(void)createPersonGroupWithName: (NSString*)name withCompletionBlock: (FaceRecognitionMSFaceAPIManagerCompletionBlock)completionBlock;
-(void)personsFromGroup: (NSString*)group withCompletionBlock: (FaceRecognitionMSFaceAPIManagerCompletionBlock)completionBlock;
-(void)deletePersonGroupWithId: (NSString*)personGroupId withCompletionBlock: (FaceRecognitionMSFaceAPIManagerCompletionBlock)completionBlock;

-(void)personFromId: (NSString*)personId andGroupId: (NSString*)groupId withCompletionBlock: (FaceRecognitionMSFaceAPIManagerCompletionBlock)completionBlock;
-(void)createPersonWithName: (NSString*)name inGroup: (NSString*)group withCompletionBlock: (FaceRecognitionMSFaceAPIManagerCompletionBlock)completionBlock;

-(void)deletePersonWithId: (NSString*)personId inGroupId: (NSString*)groupId withCompletionBlock: (FaceRecognitionMSFaceAPIManagerCompletionBlock)completionBlock;

-(void)addImageFace: (ImageDescription*)image fromPersonId: (NSString*)personId inGroup: (NSString*)group progress:(void (^)(NSProgress *uploadProgress)) uploadProgressBlock withCompletionBlock: (FaceRecognitionMSFaceAPIManagerCompletionBlock)completionBlock;
-(void)deleteFaceFromPersonId: (NSString*)personId inGroup: (NSString*)groupId andFaceId: (NSString*)faceId withCompletionBlock: (FaceRecognitionMSFaceAPIManagerCompletionBlock)completionBlock;

-(void)imageFaceFromPersonGroup: (NSString*)personGroupId person: (NSString*)personId andFace: (NSString*)faceId withCompletionBlock: (FaceRecognitionMSFaceAPIManagerCompletionBlock)completionBlock;
-(void)trainPersonGroup: (NSString*)group withCompletionBlock: (FaceRecognitionMSFaceAPIManagerCompletionBlock)completionBlock;
-(void)personGroupTrainStatus: (NSString*)group withCompletionBlock: (FaceRecognitionMSFaceAPIManagerCompletionBlock)completionBlock;
-(void)faceDetect: (UIImage*)image progress:(void (^)(NSProgress *uploadProgress))uploadProgressBlock withCompletionBlock: (FaceRecognitionMSFaceAPIManagerCompletionBlock)completionBlock;
-(void)identifyFaces: (NSArray*)faces fromGroup: (NSString*)group withCompletionBlock: (FaceRecognitionMSFaceAPIManagerCompletionBlock)completionBlock;


-(void)enrollWithImage: (ImageDescription*)image inGallery: (NSString*)gallery withCompletionBlock: (FaceRecognitionMSFaceAPIManagerCompletionBlock)completionBlock;

@end
