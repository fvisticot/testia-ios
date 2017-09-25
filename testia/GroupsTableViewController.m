//
//  GroupsTableViewController.m
//  testia
//
//  Created by frederic Visticot on 16/09/2017.
//  Copyright © 2017 fvisticot. All rights reserved.
//

#import "GroupsTableViewController.h"
#import "PersonsTableViewController.h"
#import "UtilHelper.h"

@import core;

@interface GroupsTableViewController ()
@property(nonatomic, strong) NSArray<PersonGroup*> *groups;
@end

@implementation GroupsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *addButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addGroup:)];
    self.navigationItem.rightBarButtonItem=addButtonItem;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self
                            action:@selector(loadGroups)
                  forControlEvents:UIControlEventValueChanged];
    
    [self loadGroups];
}

-(void)loadGroups
{
    [[FaceRecognitionMSFaceAPIManager shared] personGroupsWithCompletionBlock:^(FaceRecognitionMSFaceAPIManager *service, id object, NSError *error) {
        [self.refreshControl endRefreshing];
        if (!error)
        {
            _groups = object;
            [self.tableView reloadData];
        }
        else{
            [UtilHelper dialogWithMSError: error inViewController:self];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)addGroup: (id)sender
{
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle: @"AddGroup"
                                                                              message: @"Create a new group"
                                                                       preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"name";
    }];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSArray * textfields = alertController.textFields;
        UITextField * namefield = textfields[0];
        [[FaceRecognitionMSFaceAPIManager shared] createPersonGroupWithName:namefield.text withCompletionBlock:^(FaceRecognitionMSFaceAPIManager *service, id object, NSError *error) {
            if (!error)
            {
                [self loadGroups];
            } else {
                [UtilHelper dialogWithMSError: error inViewController:self];
            }
            
        }];
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - Table view data source

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _groups.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"PushSegue" sender:self];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    PersonGroup *personGroup = [_groups objectAtIndex: indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GroupTableViewCell" forIndexPath:indexPath];
    
    cell.textLabel.text = personGroup.name;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        PersonGroup *personGroup = [_groups objectAtIndex: indexPath.row];
        [[FaceRecognitionMSFaceAPIManager shared] deletePersonGroupWithId: personGroup.personGroupId withCompletionBlock:^(FaceRecognitionMSFaceAPIManager *service, id object, NSError *error) {
            if (!error)
            {
                [self loadGroups];
            } else {
                [UtilHelper dialogWithMSError: error inViewController:self];
            }
        }];
    }
}




/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/




#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    PersonGroup *personGroup = [_groups objectAtIndex: indexPath.row];
    PersonsTableViewController *controller = (PersonsTableViewController*)segue.destinationViewController;
    controller.personGroup = personGroup;
}


@end
