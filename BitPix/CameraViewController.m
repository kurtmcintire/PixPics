//
//  LaunchViewController.m
//  BitPix
//
//  Created by Matt Holmboe Kurt McIntire on 4/4/14.
//  Copyright (c) 2014 Vektor Digital. All rights reserved.
//

#import "CameraViewController.h"


@interface CameraViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIGestureRecognizerDelegate>
{
    UIImage *originalImage;
}

@property(nonatomic, weak) IBOutlet UIImageView *selectedImageView;
@property(nonatomic, weak) IBOutlet UIButton *saveButton;
@property(nonatomic, strong) UIImagePickerController *photoPicker;
@property (nonatomic) IBOutlet UIView *overlayView;
@property (nonatomic) NSMutableArray *capturedImages;


@end

@implementation CameraViewController


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
    
    _logoLabel.font = [UIFont fontWithName:@"Extrude" size:80];
    [self.saveButton setHidden:YES];
    [_selectedImageView setHidden:YES];

    
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(takePicture:)];
    tapGesture.delegate = self;
    tapGesture.numberOfTapsRequired = 2;
    tapGesture.numberOfTouchesRequired = 1;
    [_photoPicker.view addGestureRecognizer:tapGesture];
    [self.photoPicker.view setUserInteractionEnabled:YES];

    UITapGestureRecognizer *imageTapGesture = [[UITapGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(customDismissAnimation)];
    tapGesture.delegate = self;
    [self.selectedImageView addGestureRecognizer:imageTapGesture];
    [self.selectedImageView setUserInteractionEnabled:YES];
}



- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //show camera...
        [self performSelector:@selector(showPhotoPicker) withObject:nil afterDelay:0.5f];
}


- (IBAction)takePhoto:(id)sender
{
    [self.photoPicker takePicture];
//    [self performSegueWithIdentifier:@"previewViewController" sender:self];

}

-(void)didTapOnPhotoAction
{
    [self customDismissAnimation];
}


-(void)customDismissAnimation
{
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    transition.type = kCATransitionFade;
    
    [self.view.layer addAnimation:transition
                                                forKey:kCATransition];
    [_selectedImageView setHidden:YES];
}


-(void)showPhotoPicker
{
    NSLog(@"%@", @"Taking a picture...");
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        _photoPicker = [[UIImagePickerController alloc] init];
        //
        //        photoPicker.delegate = self;
        //        photoPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        //        photoPicker.allowsEditing = YES;
        //        [self presentViewController:photoPicker animated:NO completion:NULL];
        _photoPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        _photoPicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
        _photoPicker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        _photoPicker.showsCameraControls = NO;
        _photoPicker.navigationBarHidden = YES;
        _photoPicker.toolbarHidden = YES;
        
        /*
         Load the overlay view from the OverlayView nib file. Self is the File's Owner for the nib file, so the overlayView outlet is set to the main view in the nib. Pass that view to the image picker controller to use as its overlay view, and set self's reference to the view to nil.
         */
        [[NSBundle mainBundle] loadNibNamed:@"Overlay" owner:self options:nil];
        self.overlayView.frame = _photoPicker.cameraOverlayView.frame;
        _photoPicker.cameraOverlayView = self.overlayView;
        self.overlayView = nil;
        
        
        //For iphone 5+
        //Camera is 426 * 320. Screen height is 568.  Multiply by 1.333 in 5 inch to fill vertical
        
        if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
            if([UIScreen mainScreen].bounds.size.height == 568.0)
            {
                CGAffineTransform translate = CGAffineTransformMakeTranslation(0.0, 71.0);
                
                //This slots the preview exactly in the middle of the screen by moving it down 71 points
                _photoPicker.cameraViewTransform = translate;
                
                CGAffineTransform scale = CGAffineTransformScale(translate, 1.333333, 1.333333);
                _photoPicker.cameraViewTransform = scale;
            }
        }
    
        [self presentViewController:_photoPicker animated:NO completion:NULL];

    }else{
        _photoPicker = [[UIImagePickerController alloc] init];
        _photoPicker.delegate = self;
        _photoPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        _photoPicker.allowsEditing = YES;
        
        [self presentViewController:_photoPicker animated:NO completion:NULL];
        
    }
}


// This method is called when an image has been chosen from the library or taken from the camera.
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    self.saveButton.enabled = YES;
    [self.saveButton setHidden:NO];
    
    originalImage = [info valueForKey:UIImagePickerControllerOriginalImage];
    [self.capturedImages addObject:originalImage];
    
    [_selectedImageView setHidden:NO];
    [self.selectedImageView setImage:originalImage];
    
    [self finishAndUpdate];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}


- (void)finishAndUpdate
{
    [self dismissViewControllerAnimated:YES completion:NULL];
    
    if ([self.capturedImages count] > 0)
    {
        if ([self.capturedImages count] == 1)
        {
            // Camera took a single picture.
            [_selectedImageView setImage:[self.capturedImages objectAtIndex:0]];
        }
        else
        {
            // Camera took multiple pictures; use the list of images for animation.
            _selectedImageView.animationImages = self.capturedImages;
            _selectedImageView.animationDuration = 5.0;    // Show each captured photo for 5 seconds.
            _selectedImageView.animationRepeatCount = 0;   // Animate forever (show all photos).
            [_selectedImageView startAnimating];
        }
        
        // To be ready to start again, clear the captured images array.
        [self.capturedImages removeAllObjects];
    }
    
    self.photoPicker = nil;
    
    UIStoryboard *storyboard= [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PreviewViewController *pVC = [[PreviewViewController alloc]init];
    pVC = [storyboard instantiateViewControllerWithIdentifier:@"previewViewController"];
}


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


#pragma mark - View Controller Transition
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//    PreviewViewController *pVC = (PreviewViewController *)segue.destinationViewController;
//    [pVC setImage:_selectedImageView.image];
//}

@end
