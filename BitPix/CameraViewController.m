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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(takePicture)];
    tapGesture.delegate = self;
    tapGesture.numberOfTapsRequired = 2;
    tapGesture.numberOfTouchesRequired = 1;
    [_photoPicker.view addGestureRecognizer:tapGesture];
    [self.photoPicker.view setUserInteractionEnabled:YES];

}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    _logoLabel.font = [UIFont fontWithName:@"Extrude" size:80];
    [self.saveButton setHidden:YES];
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:NO];
    
    //show camera...
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        [self showImagePickerForSourceType:UIImagePickerControllerSourceTypeCamera];
    }else
    {
        [self showImagePickerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
}

- (IBAction)takePhoto:(id)sender
{
    [self.photoPicker takePicture];

}

- (void)showImagePickerForSourceType:(UIImagePickerControllerSourceType)sourceType
{
    if (self.capturedImages.count > 0)
    {
        [self.capturedImages removeAllObjects];
    }
    
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    imagePickerController.sourceType = sourceType;
    imagePickerController.delegate = self;
    

    [[NSBundle mainBundle] loadNibNamed:@"Overlay" owner:self options:nil];
    self.overlayView.frame = imagePickerController.cameraOverlayView.frame;
    imagePickerController.cameraOverlayView = self.overlayView;
    self.overlayView = nil;
    
    NSLog(@"%@", @"Taking a picture...");
    if (sourceType == UIImagePickerControllerSourceTypeCamera)
    {
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePickerController.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
        imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        imagePickerController.showsCameraControls = NO;
        imagePickerController.navigationBarHidden = YES;
        imagePickerController.toolbarHidden = YES;
        
        
        //For iphone 5+
        //Camera is 426 * 320. Screen height is 568.  Multiply by 1.333 in 5 inch to fill vertical
        
        if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
            if([UIScreen mainScreen].bounds.size.height == 568.0)
            {
                CGAffineTransform translate = CGAffineTransformMakeTranslation(0.0, 71.0);
                
                //This slots the preview exactly in the middle of the screen by moving it down 71 points
                imagePickerController.cameraViewTransform = translate;
                
                CGAffineTransform scale = CGAffineTransformScale(translate, 1.333333, 1.333333);
                imagePickerController.cameraViewTransform = scale;
            }
        }
        
    }else{
        imagePickerController.delegate = self;
        imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePickerController.allowsEditing = YES;
                
    }

    self.photoPicker = imagePickerController;
    [self presentViewController:self.photoPicker animated:NO completion:nil];
}



-(void)showPhotoPicker
{
    NSLog(@"%@", @"Taking a picture...");
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        _photoPicker = [[UIImagePickerController alloc] init];
        _photoPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        _photoPicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
        _photoPicker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        _photoPicker.showsCameraControls = NO;
        _photoPicker.navigationBarHidden = YES;
        _photoPicker.toolbarHidden = YES;
        

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
    
        [self presentViewController:_photoPicker animated:YES completion:NULL];

    }else{
        _photoPicker = [[UIImagePickerController alloc] init];
        _photoPicker.delegate = self;
        _photoPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        _photoPicker.allowsEditing = YES;
        
        [self presentViewController:_photoPicker animated:YES completion:NULL];
        
    }
}


// This method is called when an image has been chosen from the library or taken from the camera.
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    self.saveButton.enabled = YES;
    [self.saveButton setHidden:NO];
    
    originalImage = [info valueForKey:UIImagePickerControllerOriginalImage];
    [self.capturedImages addObject:originalImage];
    

    [self finishAndUpdate];
    
    UIStoryboard *storyboard= [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PreviewViewController *pVC = [[PreviewViewController alloc]init];
    pVC = [storyboard instantiateViewControllerWithIdentifier:@"previewViewController"];
    
    [pVC setImage:originalImage];
    [self.navigationController presentViewController:pVC animated:NO completion:nil];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
//    [self dismissViewControllerAnimated:NO completion:NULL];
}


- (void)finishAndUpdate
{
    [self dismissViewControllerAnimated:NO completion:NULL];
    
    if ([self.capturedImages count] > 0)
    {
    // Camera took a single picture.
    }
    
    // To be ready to start again, clear the captured images array.
    [self.capturedImages removeAllObjects];
    
    self.photoPicker = nil;
}


- (IBAction)saveImageToAlbum
{

    UIImageWriteToSavedPhotosAlbum(originalImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
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
