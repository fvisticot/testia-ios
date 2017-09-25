//
//  PersonsTableViewController.m
//  testia
//
//  Created by frederic Visticot on 16/09/2017.
//  Copyright © 2017 fvisticot. All rights reserved.
//

#import "PersonsTableViewController.h"
#import "FacesTableViewController.h"
#import "UtilHelper.h"
#import "UINavigationController+M13ProgressViewBar.h"

@interface PersonsTableViewController ()
@property(nonatomic, strong) NSArray<Person*> *persons;
@end

@implementation PersonsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = _personGroup.name;
    UIBarButtonItem *addButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionMenu:)];
    self.navigationItem.rightBarButtonItem=addButtonItem;
    
    [self loadPersons];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self
                            action:@selector(loadPersons)
                  forControlEvents:UIControlEventValueChanged];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadPersons];
}

-(void)loadPersons
{
    [[FaceRecognitionMSFaceAPIManager shared] personsFromGroup:_personGroup.name withCompletionBlock:^(FaceRecognitionMSFaceAPIManager *service, id object, NSError *error) {
        [self.refreshControl endRefreshing];
        if (!error)
        {
            _persons=object;
            [self.tableView reloadData];
        } else {
            [UtilHelper dialogWithMSError: error inViewController:self];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)actionMenu: (id)sender
{
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"Actions" message:@"Available actions" preferredStyle:UIAlertControllerStyleActionSheet];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
        // Cancel button tappped.
        [self dismissViewControllerAnimated:YES completion:^{
        }];
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Train" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [[FaceRecognitionMSFaceAPIManager shared] trainPersonGroup: _personGroup.name withCompletionBlock:^(FaceRecognitionMSFaceAPIManager *service, id object, NSError *error) {
            if (!error)
            {
                NSLog(@"Success");
            } else
            {
              [UtilHelper dialogWithMSError: error inViewController:self];
            }
        }];
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Train status" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [[FaceRecognitionMSFaceAPIManager shared] personGroupTrainStatus: _personGroup.name withCompletionBlock:^(FaceRecognitionMSFaceAPIManager *service, id object, NSError *error) {
            if (!error) {
                [UtilHelper informationDialogWithMessage: object inViewController: self];
            } else {
                [UtilHelper dialogWithMSError: error inViewController:self];
            }
        }];
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Add person" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self addPerson: nil];
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Identify person (camera)" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self identifyFromCamera];
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Identify person (library)" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self identifyFromLibrary];
    }]];
    
    // Present action sheet.
    [self presentViewController:actionSheet animated:YES completion:nil];
}

-(void)identifyFromLibrary
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:picker animated:YES completion:NULL];
}

-(void)identifyFromCamera
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *image = info[UIImagePickerControllerEditedImage];
    
    [self.navigationController showProgress];
    
    
    [[FaceRecognitionMSFaceAPIManager shared] faceDetect: image progress:^(NSProgress *uploadProgress) {
        [self.navigationController setProgress:uploadProgress.fractionCompleted animated: YES];
    } withCompletionBlock:^(FaceRecognitionMSFaceAPIManager *service, id object, NSError *error) {
        [self.navigationController finishProgress];
        if (!error && ((NSArray*)object).count > 0)
        {
            NSMutableArray *faceIds = [NSMutableArray array];
            for (NSDictionary *dic in object)
            {
                [faceIds addObject: dic[@"faceId"]];
            }
            
            [[FaceRecognitionMSFaceAPIManager shared] identifyFaces:faceIds fromGroup: _personGroup.name withCompletionBlock:^(FaceRecognitionMSFaceAPIManager *service, id object, NSError *error) {
                if (!error)
                {
                    NSLog(@"Success");
                    NSMutableString *message = [[NSMutableString alloc] init];
                    for (NSDictionary *dic in object)
                    {
                        NSArray *candidates = dic[@"candidates"];
                        NSDictionary * candidateDic = [candidates firstObject];
                        
                        double confidence = [candidateDic[@"confidence"] doubleValue];
                        NSString *personId = candidateDic[@"personId"];
                        Person *person = [self personFromPersonId: personId];
                        
                        if (person)
                        {
                            NSString *messageIt = [NSString stringWithFormat: @"Person: %@, confidence: %f", person.name, confidence];
                            [message appendString: messageIt];
                            [message appendString:@"\n"];
                        }
                    }
                    
                    
                    UIAlertController * alertController = [UIAlertController alertControllerWithTitle: @"Identify"
                                                                                              message: message
                                                                                       preferredStyle:UIAlertControllerStyleAlert];
                    
                    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                        
                    }]];
                    
                    [self presentViewController:alertController animated:YES completion:nil];
                } else {
                    [UtilHelper dialogWithMSError: error inViewController:self];
                }
            }];
        } else {
            [UtilHelper dialogWithMSError: error inViewController:self];
        }
    }];
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

-(Person*)personFromPersonId: (NSString*)personId
{
    for (Person *person in _persons)
    {
        if ([person.personId isEqualToString: personId])
        {
            return person;
        }
    }
    return nil;
}

-(void)addPerson: (id)sender
{
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle: @"Add Person"
                                                                              message: @"Create a new person"
                                                                       preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"name";
    }];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSArray * textfields = alertController.textFields;
        UITextField * namefield = textfields[0];
        [[FaceRecognitionMSFaceAPIManager shared] createPersonWithName: namefield.text inGroup:_personGroup.name withCompletionBlock:^(FaceRecognitionMSFaceAPIManager *service, id object, NSError *error) {
            if (!error)
            {
                [self loadPersons];
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
    return _persons.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PersonTableViewCell" forIndexPath:indexPath];
    Person *person = [_persons objectAtIndex: indexPath.row];
    cell.textLabel.text = person.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)person.persistedFaceIds.count];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"PushSegue" sender:self];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Person *person = [_persons objectAtIndex: indexPath.row];
        [[FaceRecognitionMSFaceAPIManager shared] deletePersonWithId: person.personId inGroupId: _personGroup.personGroupId withCompletionBlock:^(FaceRecognitionMSFaceAPIManager *service, id object, NSError *error) {
            if (!error) {
                [self loadPersons];
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
    FacesTableViewController *controller = (FacesTableViewController*)segue.destinationViewController;
    NSIndexPath *indexPath = self.tableView.indexPathForSelectedRow;
    Person *person = [_persons objectAtIndex: indexPath.row];
    controller.person=person;
    controller.personGroup = _personGroup;
}


@end
