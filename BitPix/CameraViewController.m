//
//  LaunchViewController.m
//  BitPix
//
//  Created by Matt Holmboe Kurt McIntire on 4/4/14.
//  Copyright (c) 2014 Vektor Digital. All rights reserved.
//

#import "CameraViewController.h"
BOOL firstLaunch;

@interface CameraViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIGestureRecognizerDelegate>
{
    UIImage *originalImage;
}

@property(nonatomic, weak) IBOutlet UIButton *saveButton;
@property(nonatomic, strong) UIImagePickerController *photoPicker;
@property (nonatomic) IBOutlet UIView *overlayView;

@property (nonatomic, strong) NSMutableArray *pixelatedImagesArray;
@property (nonatomic, strong) UIImageView *pixelatedImageView;


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
    _logoLabel.font = [UIFont fontWithName:@"Extrude" size:80];
    [self.saveButton setHidden:YES];
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    
    self.pixelatedImagesArray = [@[] mutableCopy];
    
    if (firstLaunch) {
        [self setupDisplayFiltering];
        [self performSelector:@selector(showPicker) withObject:nil afterDelay:2.0];
        firstLaunch = NO;
        
    }else
    {
        [self showPicker];
    }
    
}


-(void)showPicker
{
    //show camera...
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        [self showImagePickerForSourceType:UIImagePickerControllerSourceTypeCamera];
    }else
    {
        [self showImagePickerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
}

- (void)setupDisplayFiltering;
{
    
    [_logoLabel setHidden:NO];

    CGRect originalRect = self.view.bounds;
    
    // screenshot of background image view
    UIImage * capturedImage = nil;
    UIGraphicsBeginImageContextWithOptions(originalRect.size, NO, 1.0);

    CGContextRef cgContext = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(cgContext, kCGInterpolationNone);
    [[self.view layer] renderInContext:cgContext];
    capturedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [self performSelector:@selector(pixelateInDisplay:) withObject:capturedImage afterDelay:0.05f];

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

}

-(void)pixelateInDisplay:(UIImage *)image
{
    // build an array of images at different filter levels
    GPUImagePixellateFilter *pixellateFilter = [[GPUImagePixellateFilter alloc] init];
    for (NSInteger index = 1; index < 50; index++){
        pixellateFilter.fractionalWidthOfAPixel = (50-index)*0.0009;
        UIImage * filteredImage = [pixellateFilter imageByFilteringImage:image];
        [self.pixelatedImagesArray addObject:filteredImage];
    }
    
    [self showPixellatedImageView];
    
    [self performSelector:@selector(pixelateOutDisplay:) withObject:image afterDelay:1.0f];


}

- (void) showPixellatedImageView {
    
    // create a UIImageView from the array of pixellated images, add to view
    UIImageView * pixelView = [[UIImageView alloc] initWithFrame:self.view.frame];
    pixelView.animationImages = self.pixelatedImagesArray;
    pixelView.animationDuration=.50;
    pixelView.animationRepeatCount=1;
    pixelView.image = [self.pixelatedImagesArray lastObject];
    [pixelView startAnimating];
    
    self.pixelatedImageView = pixelView;
    [self.view insertSubview:self.pixelatedImageView aboveSubview:self.view];
    
}

- (IBAction)takePhoto:(id)sender
{
    [self.photoPicker takePicture];

}

- (void)showImagePickerForSourceType:(UIImagePickerControllerSourceType)sourceType
{

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
//    [self dismissViewControllerAnimated:NO completion:NULL];
}


@end
