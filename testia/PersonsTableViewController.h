//
//  PersonsTableViewController.h
//  testia
//
//  Created by frederic Visticot on 16/09/2017.
//  Copyright © 2017 fvisticot. All rights reserved.
//

#import <UIKit/UIKit.h>

@import core;

@interface PersonsTableViewController : UITableViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property(nonatomic, strong) PersonGroup *personGroup;
@end