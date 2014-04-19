//
//  LaunchViewController.m
//  BitPix
//
//  Created by Matt Holmboe Kurt McIntire on 4/4/14.
//  Copyright (c) 2014 Vektor Digital. All rights reserved.
//

#import "CameraViewController.h"
#import <Canvas/CSAnimationView.h>

BOOL firstLaunch;
BOOL firstCameraLaunch;


@interface CameraViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIGestureRecognizerDelegate>
{
    UIImage *originalImage;
}

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (weak, nonatomic) IBOutlet CSAnimationView *bitPixView;
@property(nonatomic, strong) UIImagePickerController *photoPicker;
@property (nonatomic) IBOutlet UIView *overlayView;
@property (nonatomic, strong) NSMutableArray *pixelatedImagesArray;
@property (nonatomic, strong) UIImageView *pixelatedImageView;
@property (weak, nonatomic) IBOutlet UIButton *rotateCameraButton;
@property (weak, nonatomic) IBOutlet UIButton *albumButton;
@property (weak, nonatomic) IBOutlet UIButton *cameraButton;
@property (nonatomic, strong) NSTimer *timer;




- (IBAction)takePhoto:(id)sender;
- (IBAction)albumAction:(id)sender;
- (IBAction)rotateCamera:(id)sender;
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
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    firstLaunch = YES;
    firstCameraLaunch = YES;

    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(takePicture)];
    tapGesture.delegate = self;
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.numberOfTouchesRequired = 1;
    [_photoPicker.view addGestureRecognizer:tapGesture];
    [self.photoPicker.view setUserInteractionEnabled:YES];
        
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    [_logoLabel setHidden:YES];
    [self.backgroundImage setAlpha:1.0];
    [self.logoLabel setAlpha:0.0];
    _logoLabel.font = [UIFont fontWithName:@"Extrude" size:90];
    
    self.pixelatedImagesArray = [NSMutableArray array];
    
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
        //For iphone 4+
        if([UIScreen mainScreen].bounds.size.height == 480.0)
        {
            [self.backgroundImage setImage:[UIImage imageNamed:@"launchImage_960.png"]];
            
        }else{
            //For iphone 5
            [self.backgroundImage setImage:[UIImage imageNamed:@"launchImage.png"]];
        }
    }

}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    
    [_timer invalidate];
    _timer = nil;
    
    self.pixelatedImagesArray = nil;
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    
    if (firstLaunch) {
        [self setupDisplayFiltering];
        firstLaunch = NO;
    }else
    {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        {
            [self performSelector:@selector(showPicker) withObject:nil afterDelay:0.05];
        }
    }
}


-(void)showPicker
{
    //show camera...
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        [self showImagePickerForSourceType:UIImagePickerControllerSourceTypeCamera];
        if (firstCameraLaunch) {
            [self setUpTimer];
            firstCameraLaunch = NO;
        }
    }
    else
    {
        [self showImagePickerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        [_timer invalidate];
        _timer = nil;
    }
    
}


- (void)setupDisplayFiltering;
{
    
    [_logoLabel setHidden:NO];
    
    // screenshot of background image view
    UIImage * capturedImage = nil;
    UIGraphicsBeginImageContextWithOptions(self.backgroundImage.bounds.size, NO, 1.0);
    CGContextRef cgContext = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(cgContext, kCGInterpolationNone);
    [[self.backgroundImage layer] renderInContext:cgContext];
    capturedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [self performSelector:@selector(pixelateOutDisplay:) withObject:capturedImage afterDelay:0.5f];
}

-(void)pixelateOutDisplay:(UIImage *)image
{
    // build an array of images at different filter levels
    GPUImagePixellateFilter *pixellateFilter = [[GPUImagePixellateFilter alloc] init];
    for (NSInteger index = 1; index < 60; index++){
        pixellateFilter.fractionalWidthOfAPixel = index*0.005;
        
        UIImage * filteredImage = [pixellateFilter imageByFilteringImage:image];
        [self.pixelatedImagesArray addObject:filteredImage];
    }
    
    [self showPixellatedImageView];
    [self performSelector:@selector(performAnimations:) withObject:image afterDelay:0.600];
}


-(void)performAnimations:(UIImage *)image
{
    [self.view bringSubviewToFront:self.bitPixView];
    [self.view startCanvasAnimation];
    [self.logoLabel setAlpha:1.0];

    [UIView animateWithDuration:0.60f animations:^{
        [self.backgroundImage setAlpha:0];
    }completion:^(BOOL finished){
             [UIView animateWithDuration:0.50f delay:1.25f options:UIViewAnimationOptionCurveEaseInOut animations:^{
                 [self.pixelatedImageView setAlpha:0];
                 self.pixelatedImagesArray = nil;
                 self.pixelatedImageView = nil;
            }completion:^(BOOL finished){
                         [UIView animateWithDuration:0.20f animations:^{
                         [self.logoLabel setAlpha:0.0];
                         }completion:^(BOOL finished){
                             [self performSelector:@selector(showPicker) withObject:nil afterDelay:0.05];
                         }];
            }];
    }];
}


- (void) showPixellatedImageView {
    
    // create a UIImageView from the array of pixellated images, add to view
    UIImageView * pixelView = [[UIImageView alloc] initWithFrame:self.backgroundImage.frame];
    pixelView.animationImages = self.pixelatedImagesArray;
    pixelView.animationDuration=0.500;
    pixelView.animationRepeatCount=1;
    pixelView.image = [self.pixelatedImagesArray lastObject];
    [pixelView startAnimating];
    
    self.pixelatedImageView = pixelView;
    [self.view insertSubview:self.pixelatedImageView aboveSubview:self.view];
}


-(void)pixelateCameraButton
{
    
    if (self.pixelatedImagesArray.count==0) {

        self.pixelatedImagesArray = [[NSMutableArray alloc]init];
        
        // build an array of images at different filter levels
        GPUImagePixellateFilter *pixellateFilter = [[GPUImagePixellateFilter alloc] init];
        for (NSInteger index = 1; index < 60; index++){
            pixellateFilter.fractionalWidthOfAPixel = (60-index)*0.001;
            
            
            UIImage * filteredImage = [pixellateFilter imageByFilteringImage:self.cameraButton.imageView.image];
            [self.pixelatedImagesArray addObject:filteredImage];
        }
    }

    [self showPixellatedCameraImageView];
}


- (void) showPixellatedCameraImageView
{
    [self.pixelatedImageView removeFromSuperview];

    // create a UIImageView from the array of pixellated images, add to view
    UIImageView * pixelView = [[UIImageView alloc] initWithFrame:self.cameraButton.frame];
    pixelView.animationImages = self.pixelatedImagesArray;
    pixelView.animationDuration=0.500;
    pixelView.animationRepeatCount=1;
    pixelView.image = [self.pixelatedImagesArray lastObject];
    [pixelView startAnimating];
    
    self.pixelatedImageView = pixelView;
    [self.view insertSubview:self.pixelatedImageView aboveSubview:self.view];
}



- (void) setUpTimer {
    
        [NSTimer scheduledTimerWithTimeInterval:6
                                         target:self
                                       selector:@selector(pixelateCameraButton)
                                       userInfo:nil
                                        repeats:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    self.pixelatedImagesArray = nil;
    
}

- (void)showImagePickerForSourceType:(UIImagePickerControllerSourceType)sourceType
{

    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    imagePickerController.sourceType = sourceType;
    imagePickerController.delegate = self;
    


    NSLog(@"%@", @"Taking a picture...");
    if (sourceType == UIImagePickerControllerSourceTypeCamera)
    {
        
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePickerController.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
        imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        imagePickerController.showsCameraControls = NO;
        imagePickerController.navigationBarHidden = YES;
        imagePickerController.toolbarHidden = YES;
        
        [[NSBundle mainBundle] loadNibNamed:@"Overlay" owner:self options:nil];
        self.overlayView.frame = imagePickerController.cameraOverlayView.frame;
        imagePickerController.cameraOverlayView = self.overlayView;
        self.overlayView = nil;
        
        if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
            //For iphone 5+
            //Camera is 426 * 320. Screen height is 568.  Multiply by 1.333 in 5 inch to fill vertical
            if([UIScreen mainScreen].bounds.size.height == 568.0)
            {
                CGAffineTransform translate = CGAffineTransformMakeTranslation(0.0, 71.0);
                
                imagePickerController.cameraViewTransform = translate;
                
                CGAffineTransform scale = CGAffineTransformScale(translate, 1.333333, 1.333333);
                imagePickerController.cameraViewTransform = scale;
            }else{
                //For iphone 4+
                //Camera is 426 * 320. Screen height is 480.  Multiply by 1.1267 in 5 inch to fill vertical
                CGAffineTransform translate = CGAffineTransformMakeTranslation(0.0, 30.0);
                
                imagePickerController.cameraViewTransform = translate;
                
                CGAffineTransform scale = CGAffineTransformScale(translate, 1.18, 1.18);
                imagePickerController.cameraViewTransform = scale;
            }
        }
        
    }else{
        imagePickerController.delegate = self;
        imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }

    self.photoPicker = imagePickerController;
    [self presentViewController:self.photoPicker animated:NO completion:nil];
    
}



- (IBAction)takePhoto:(id)sender
{
    [self.photoPicker takePicture];
}

- (IBAction)albumAction:(id)sender {
    

    [self dismissViewControllerAnimated:NO completion:NULL];
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.allowsEditing = NO;
    imagePicker.delegate = self;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (IBAction)rotateCamera:(id)sender {
    
    if (_photoPicker.cameraDevice == UIImagePickerControllerCameraDeviceFront) {
        _photoPicker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
    }else
    {
        _photoPicker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
    }
    _rotateCameraButton.selected = !_rotateCameraButton.selected;
}

// This method is called when an image has been chosen from the library or taken from the camera.
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    originalImage = [info valueForKey:UIImagePickerControllerOriginalImage];
    
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        //assume that the image is loaded in landscape mode from disk
        if (!_rotateCameraButton.selected) {
            if ((originalImage.imageOrientation == UIImageOrientationUp) || (originalImage.imageOrientation == UIImageOrientationDown) ||  (originalImage.imageOrientation == UIImageOrientationLeft))
            {
                originalImage = [[UIImage alloc] initWithCGImage: originalImage.CGImage
                                                           scale: 1.0
                                                     orientation: UIImageOrientationLeftMirrored];
            }
        }
        
        else{
            if ((originalImage.imageOrientation == UIImageOrientationUp) || (originalImage.imageOrientation == UIImageOrientationDown) ||  (originalImage.imageOrientation == UIImageOrientationLeft))
            {
                originalImage = [[UIImage alloc] initWithCGImage: originalImage.CGImage
                                                           scale: 1.0
                                                     orientation: UIImageOrientationRight];
            }
        }
    }

    self.photoPicker = nil;

    UIStoryboard *storyboard= [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PreviewViewController *pVC = [[PreviewViewController alloc]init];
    pVC = [storyboard instantiateViewControllerWithIdentifier:@"previewViewController"];
    [pVC setImage:originalImage];
        
    [self dismissViewControllerAnimated:NO completion:NULL];

    [self.navigationController presentViewController:pVC animated:NO completion:nil];
}



- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:NO completion:NULL];
    [self setupDisplayFiltering];
}



@end
