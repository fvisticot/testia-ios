//
//  ActionViewController.m
//  actionextension
//
//  Created by frederic Visticot on 16/09/2017.
//  Copyright © 2017 fvisticot. All rights reserved.
//

#import "ActionViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <ImageIO/CGImageProperties.h>
#import <ImageIO/CGImageSource.h>

@import AssetsLibrary;

@interface ActionViewController ()

@property(strong,nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ActionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Get the item[s] we're handling from the extension context.
    
    // For example, look for an image and place it into an image view.
    // Replace this with something appropriate for the type[s] your extension supports.
    BOOL imageFound = NO;
    for (NSExtensionItem *item in self.extensionContext.inputItems) {
        for (NSItemProvider *itemProvider in item.attachments) {
            if ([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeImage]) {
                // This is an image. We'll load it, then place it in our image view.
                __weak UIImageView *imageView = self.imageView;
                
                [itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeImage options:nil completionHandler:^(NSData *imageData, NSError *error) {
                    CGImageSourceRef imageDataRef= CGImageSourceCreateWithData((CFDataRef)imageData, NULL);
                    NSDictionary *metadata = (__bridge NSDictionary *)CGImageSourceCopyPropertiesAtIndex(imageDataRef, 0, NULL);
                    NSDictionary *exifGPSDictionary = [metadata objectForKey:(NSString *)kCGImagePropertyGPSDictionary];
                    
                    if(exifGPSDictionary) {
                        NSLog(@"WOO! %@", exifGPSDictionary);
                    }
                }];
                
                /*[itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeImage options:nil completionHandler:^(UIImage *image, NSError *error) {
                    if(image) {
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            [imageView setImage:image];
                        }];
                        
                        NSData* pngData =  UIImagePNGRepresentation(image);
                        
                        
                        
                        NSData *jpegData = UIImageJPEGRepresentation(image, 1.0);
                        CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)pngData, NULL);
                        CFDictionaryRef imageMetaData = CGImageSourceCopyPropertiesAtIndex(source,0,NULL);
                        
                        CGImageSourceRef imageData= CGImageSourceCreateWithData((CFDataRef)pngData, NULL);
                        
                        NSDictionary *metadata = (__bridge NSDictionary *)CGImageSourceCopyPropertiesAtIndex(imageData, 0, NULL);
                        
                        NSDictionary *exifGPSDictionary = [metadata objectForKey:(NSString *)kCGImagePropertyGPSDictionary];
                        
                        if(exifGPSDictionary) {
                            NSLog(@"WOO! %@", exifGPSDictionary);
                        }
                        
                        NSLog(@"");
                        //CGImageSourceRef source = CGImageSourceCreateWithData((CFDataRef)pngData, NULL);
                        //NSDictionary *metadata = (NSDictionary *) CGImageSourceCopyPropertiesAtIndex(source, 0, NULL);

                    }
                }];
                */
                imageFound = YES;
                break;
            }
        }
        
        if (imageFound) {
            // We only handle one image, so stop looking for more.
            break;
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)done {
    // Return any edited content to the host app.
    // This template doesn't do anything, so we just echo the passed in items.
    [self.extensionContext completeRequestReturningItems:self.extensionContext.inputItems completionHandler:nil];
}

@end
