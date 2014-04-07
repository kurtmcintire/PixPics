//
//  LaunchViewController.m
//  BitPix
//
//  Created by Matt Holmboe Kurt McIntire on 4/4/14.
//  Copyright (c) 2014 Vektor Digital. All rights reserved.
//

#import "LaunchViewController.h"

BOOL hasLoadedCamera;


@interface LaunchViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
    UIImage *originalImage;
}

@property(nonatomic, weak) IBOutlet UIImageView *selectedImageView;
@property(nonatomic, weak) IBOutlet UIBarButtonItem *filterButton;

@end

@implementation LaunchViewController




- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    hasLoadedCamera = NO;
    
    _logoLabel.font = [UIFont fontWithName:@"Extrude" size:80];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
//    [self launchAnimation];
//    [self performSelector:@selector(launchAnimation) withObject:nil afterDelay:2.0f];
}



- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //show camera...
    if (!hasLoadedCamera)
        [self performSelector:@selector(showPhotoPicker) withObject:nil afterDelay:0.25f];
    hasLoadedCamera = YES;
    
}

//- (void)launchAnimation {
//    [self performSegueWithIdentifier:@"launchToCameraSegue" sender:self];
//    [UIView animateWithDuration:2
//                     animations:^{
//                         
//                     completion:^(BOOL finished) {
//                         [self performSegueWithIdentifier:@"launchToCameraSegue" sender:self];
//                     }
//     ];
//}



-(void)showPhotoPicker
{
    NSLog(@"%@", @"Taking a picture...");
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *photoPicker = [[UIImagePickerController alloc] init];
        
        photoPicker.delegate = self;
        photoPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        photoPicker.allowsEditing = YES;
        //        photoPicker.modalPresentationStyle = UIModalPresentationCurrentContext;
        
        [self presentViewController:photoPicker animated:NO completion:NULL];
    }else{
        UIImagePickerController *photoPicker = [[UIImagePickerController alloc] init];
        photoPicker.delegate = self;
        photoPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        photoPicker.allowsEditing = YES;
        
        [self presentViewController:photoPicker animated:NO completion:NULL];
        
    }
}

//- (IBAction)photoFromCamera
//{
//    UIImagePickerController *photoPicker = [[UIImagePickerController alloc] init];
//
//    photoPicker.delegate = self;
//    photoPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
//
//    [self presentViewController:photoPicker animated:YES completion:NULL];
//
//}
//
//- (IBAction)photoFromAlbum
//{
//    UIImagePickerController *photoPicker = [[UIImagePickerController alloc] init];
//    photoPicker.delegate = self;
//    photoPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
//
//    [self presentViewController:photoPicker animated:YES completion:NULL];
//
//}

- (void)imagePickerController:(UIImagePickerController *)photoPicker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //    self.saveButton.enabled = YES;
    self.filterButton.enabled = YES;
    
    originalImage = [info valueForKey:UIImagePickerControllerOriginalImage];
    
    [self.selectedImageView setImage:originalImage];
    
    [photoPicker dismissViewControllerAnimated:YES completion:nil];
}

//-(void) imagePickerControllerDidCancel:(UIImagePickerController *)picker
//{
//    //do nothing
//}

- (IBAction)saveImageToAlbum
{
    UIImageWriteToSavedPhotosAlbum(self.selectedImageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    NSString *alertTitle;
    NSString *alertMessage;
    
    if(!error)
    {
        alertTitle   = @"Image Saved";
        alertMessage = @"Image saved to photo album successfully.";
    }
    else
    {
        alertTitle   = @"Error";
        alertMessage = @"Unable to save to photo album.";
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:alertTitle
                                                    message:alertMessage
                                                   delegate:self
                                          cancelButtonTitle:@"Okay"
                                          otherButtonTitles:nil];
    [alert show];
}
@end
