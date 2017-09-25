//
//  UtilHelper.m
//  testia
//
//  Created by frederic Visticot on 18/09/2017.
//  Copyright © 2017 fvisticot. All rights reserved.
//

#import "UtilHelper.h"


@implementation UtilHelper

+(void)informationDialogWithMessage: (NSString*)message inViewController: (UIViewController*)viewController
{
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle: @"Information"
                                                                              message: message
                                                                       preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
    }]];
    
    [viewController presentViewController:alertController animated:YES completion:nil];
}

+(void)dialogWithMSError: (NSError*)error inViewController: (UIViewController*)viewController
{
    NSString *title =@"Error";
    NSString *message = @"Unknown error";
    if (error) {
        NSData *data= error.userInfo[@"com.alamofire.serialization.response.error.data"];
        if (data != nil) {
            NSError *jsonError;
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data
                                                            options:NSJSONReadingMutableContainers
                                                              error:&jsonError];
        
        
            if (!jsonError) {
                if (dic) {
                    title = dic[@"error"][@"code"];
                    message = dic[@"error"][@"message"];
                }
            }
        } else {
            message = error.localizedDescription;
        }
    } else {
        message = @"Error is null";
    }
    
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle: title
                                                                              message: message
                                                                       preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
    }]];
    
    [viewController presentViewController:alertController animated:YES completion:nil];
}
@end
