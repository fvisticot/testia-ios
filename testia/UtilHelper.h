//
//  UtilHelper.h
//  testia
//
//  Created by frederic Visticot on 18/09/2017.
//  Copyright © 2017 fvisticot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UtilHelper : NSObject

+(void)dialogWithMSError: (NSError*)error inViewController: (UIViewController*)viewController;
+(void)informationDialogWithMessage: (NSString*)message inViewController: (UIViewController*)viewController;
@end
