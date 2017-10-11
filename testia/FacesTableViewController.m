//
//  FacesTableViewController.m
//  testia
//
//  Created by frederic Visticot on 16/09/2017.
//  Copyright © 2017 fvisticot. All rights reserved.
//

#import "FacesTableViewController.h"
#import "FaceTableViewCell.h"
#import "UINavigationController+M13ProgressViewBar.h"
#import "UtilHelper.h"

@import Photos;

@interface FacesTableViewController ()

@end

@implementation FacesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = _person.name;
    UIBarButtonItem *addButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(actionMenu:)];
    self.navigationItem.rightBarButtonItem=addButtonItem;
    [self loadPerson];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self
                            action:@selector(loadPerson)
                  forControlEvents:UIControlEventValueChanged];
    
}

-(void)loadPerson
{
    [[FaceRecognitionMSFaceAPIManager shared] personFromId:_person.personId andGroupId:_personGroup.personGroupId withCompletionBlock:^(FaceRecognitionMSFaceAPIManager *service, id object, NSError *error) {
        [self.refreshControl endRefreshing];
        if (!error)
        {
            _person=object;
            [self.tableView reloadData];
            self.title = [NSString stringWithFormat:@"%@ (%lu)", _person.name, (unsigned long)_person.persistedFaceIds.count];
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
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Camera" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self addFaceFromCamera: nil];
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Library" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self addFaceFromLibrary: nil];
    }]];
    
    // Present action sheet.
    [self presentViewController:actionSheet animated:YES completion:nil];
}


-(void)addFaceFromCamera: (id)sender
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:picker animated:YES completion:NULL];
}

-(void)addFaceFromLibrary: (id)sender
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *image = info[UIImagePickerControllerEditedImage];
    __block NSString *localIdentifier = nil;
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
    if ([picker sourceType] == UIImagePickerControllerSourceTypeCamera) {
         [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            PHAssetChangeRequest *changeRequest = [PHAssetChangeRequest creationRequestForAssetFromImage:[info valueForKey:UIImagePickerControllerOriginalImage]];
             PHObjectPlaceholder *placeHolder =  changeRequest.placeholderForCreatedAsset;
             localIdentifier=placeHolder.localIdentifier;
        } completionHandler:^(BOOL success, NSError *error) {
            if (success) {
                NSLog(@"Success");
                PHFetchResult<PHAsset *> *assets = [PHAsset fetchAssetsWithLocalIdentifiers: @[localIdentifier] options:nil];
                PHAsset *asset = [assets firstObject];
                ImageDescription *imageDescription = [[ImageDescription alloc] init];
                imageDescription.image=image;
                imageDescription.userData=asset.localIdentifier;
                [self addImageFace:imageDescription];
            }
            else {
                NSLog(@"write error : %@",error);
                [UtilHelper informationDialogWithMessage: error.localizedDescription inViewController: self];
            }
        }];
    } else {
        NSURL* localUrl = (NSURL *)[info valueForKey:UIImagePickerControllerReferenceURL];
        ImageDescription *imageDescription = [[ImageDescription alloc] init];
        imageDescription.image=image;
        NSString *localIdentifier=[[[localUrl absoluteString] componentsSeparatedByString:@"id="] lastObject];
        imageDescription.userData=localIdentifier;
        [self addImageFace:imageDescription];
    }
}

-(void)addImageFace: (ImageDescription*)imageDescription {
    [self.navigationController showProgress];
    [[FaceRecognitionMSFaceAPIManager shared] addImageFace:imageDescription fromPersonId:_person.personId inGroup:_personGroup.name progress:^(NSProgress *uploadProgress) {
        [self.navigationController setProgress:uploadProgress.fractionCompleted animated: YES];
    } withCompletionBlock:^(FaceRecognitionMSFaceAPIManager *service, id object, NSError *error) {
        [self.navigationController finishProgress];
        if (!error)
        {
            [self loadPerson];
        } else{
            [UtilHelper dialogWithMSError: error inViewController:self];
        }
    }];
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
    return _person.persistedFaceIds.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FaceTableViewCell *cell = (FaceTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"FaceTableViewCell" forIndexPath:indexPath];
    NSString *faceId = [_person.persistedFaceIds objectAtIndex: indexPath.row];
    cell.faceIdLabel.text = faceId;
    
    /*
    [[FaceRecognitionMSFaceAPIManager shared] imageFaceFromPersonGroup:_personGroup.personGroupId person:_person.personId andFace:faceId withCompletionBlock:^(FaceRecognitionMSFaceAPIManager *service, id object, NSError *error) {
        if (!error)
        {
            cell.faceIdLabel.text = faceId;
            NSString *userData = object[@"userData"];
            if (userData && (NSObject*)userData != [NSNull null])
            {
                NSString *localIdentifier = userData;
                if ([userData containsString:@"id"]) {
                    localIdentifier = [[userData componentsSeparatedByString:@"id="] lastObject];
                }
                NSArray *identifiers = @[localIdentifier];
                PHFetchResult<PHAsset *> * assetsFetchResult= [PHAsset fetchAssetsWithLocalIdentifiers: identifiers options:nil];
                
                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
                dispatch_async(queue, ^(void) {
                    [assetsFetchResult enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idx, BOOL *stop1) {
                        if(asset){
                            [[PHImageManager defaultManager] requestImageForAsset: asset targetSize: CGSizeMake(80, 50) contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    cell.faceImageView.image=result;
                                });
                            }];
                        }
                    }];
                });
                
            }
        }
    }];
     */
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSString *faceId = [_person.persistedFaceIds objectAtIndex: indexPath.row];
        [[FaceRecognitionMSFaceAPIManager shared] deleteFaceFromPersonId:_person.personId inGroup:_personGroup.personGroupId andFaceId:faceId withCompletionBlock:^(FaceRecognitionMSFaceAPIManager *service, id object, NSError *error) {
            if (!error)
            {
                
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
