//
//  Person.h
//  core
//
//  Created by frederic Visticot on 16/09/2017.
//  Copyright © 2017 fvisticot. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Person : NSObject
@property(nonatomic, strong) NSString *name;
@property(nonatomic, strong) NSString *personId;
@property(nonatomic, strong) NSArray<NSString*> *persistedFaceIds;
@end
