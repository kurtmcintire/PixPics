//
//  PreviewViewController.m
//  BitPix
//
//  Created by Matt Holmboe Kurt McIntire on 4/4/14.
//  Copyright (c) 2014 Vektor Digital. All rights reserved.
//

#import "PreviewViewController.h"
#import <GPUImageOutput.h>

typedef enum SocialButtonTags
{
    SocialButtonTagFacebook,
    SocialButtonTagTwitter,
    
} SocialButtonTags;

@interface PreviewViewController ()
@property (weak, nonatomic) IBOutlet CSAnimationView *facebookAnimationView;
@property (weak, nonatomic) IBOutlet CSAnimationView *twitterAnimationView;
@property (weak, nonatomic) IBOutlet CSAnimationView *checkmarkAnimationView;
@property (weak, nonatomic) IBOutlet CSAnimationView *cancelAnimationView;

@property (weak, nonatomic) IBOutlet UIButton *facebookButton;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UIButton *twitterButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

@property (nonatomic, strong) NSMutableArray *pixelatedImagesArray;
@property (nonatomic, strong) UIImageView *pixelatedImageView;
@property (nonatomic, strong) UIImageView *initialImageView;


@end

@implementation PreviewViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:NO];
    
    
    self.initialImageView = [[UIImageView alloc] initWithFrame:self.imageView.frame];
    [self.initialImageView setContentMode:UIViewContentModeScaleAspectFit];


    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
        //iPhone 5 or 5s
        if([UIScreen mainScreen].bounds.size.height == 568.0)
        {
            CGAffineTransform translate = CGAffineTransformMakeTranslation(0.0, 0.0);
            self.initialImageView.transform = translate;
            CGAffineTransform scale = CGAffineTransformScale(translate, 1.333, 1.333);
            self.initialImageView.transform = scale;
        }
        //iPhone 4 or 4s
        else{
            
            CGAffineTransform translate = CGAffineTransformMakeTranslation(0.0, 0.0);
            self.initialImageView.transform = translate;
            CGAffineTransform scale = CGAffineTransformScale(translate, 1.18, 1.18);
            self.initialImageView.transform = scale;
        }
    }
    
    self.initialImageView.alpha = 1.0f;
    [self.initialImageView setImage:_image];
    [self.view insertSubview:self.initialImageView aboveSubview:self.imageView];

    [self.pixelatedImageView setAlpha:0.0f];
    self.facebookAnimationView.alpha = 0.0f;
    self.twitterAnimationView.alpha = 0.0f;
    self.checkmarkAnimationView.alpha = 0.0f;
    self.cancelAnimationView.alpha = 0.0f;
    self.pixelatedImagesArray = [@[] mutableCopy];
    
    [self.pixelatedImageView setContentMode:UIViewContentModeScaleAspectFill];
    
    [self performSelector:@selector(setupDisplayFiltering) withObject:nil afterDelay:0.05f];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:NO];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    
    
    UISwipeGestureRecognizer *swipeUpGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(dismissView)];
    [swipeUpGestureRecognizer setDirection:UISwipeGestureRecognizerDirectionDown];
    [swipeUpGestureRecognizer setNumberOfTouchesRequired:1];
    [self.view addGestureRecognizer:swipeUpGestureRecognizer];
    
    [_saveButton setImage:[UIImage imageNamed:@"download02.png"] forState:UIControlStateNormal];
    [_saveButton setImage:[UIImage imageNamed:@"ok.png"] forState:UIControlStateSelected];
    [_saveButton setImage:[UIImage imageNamed:@"ok.png"] forState:UIControlStateDisabled];
}

-(void)dismissView
{
    [self dismissViewControllerAnimated:YES completion:nil];

}

- (void)setupDisplayFiltering;
{
    self.pixelatedImagesArray = [[NSMutableArray alloc]init];
    
    CGRect originalRect = self.initialImageView.bounds;
    
    // screenshot of background image view
    UIImage * capturedImage = nil;
    if ([[UIScreen mainScreen] scale] == 2.0) {
        UIGraphicsBeginImageContextWithOptions(originalRect.size, NO, 1.0);
    } else {
        UIGraphicsBeginImageContext(originalRect.size);
    }
    CGContextRef cgContext = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(cgContext, kCGInterpolationDefault);
    [[self.initialImageView layer] renderInContext:cgContext];
    capturedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // build an array of images at different filter levels
    GPUImagePixellateFilter *pixellateFilter = [[GPUImagePixellateFilter alloc] init];
    for (NSInteger index = 1; index < 60; index++){
        pixellateFilter.fractionalWidthOfAPixel = index*0.00021;
        UIImage *filteredImage = [pixellateFilter imageByFilteringImage:capturedImage];
        [self.pixelatedImagesArray addObject:filteredImage];
    }
    
    [self performSelector:@selector(showPixellatedImageView) withObject:nil afterDelay:0.005f];

}


- (void) showPixellatedImageView {
    
    // create a UIImageView from the array of pixellated images, add to view
    UIImageView *pixelView = [[UIImageView alloc] initWithFrame:self.initialImageView.frame];
    [pixelView setContentMode:UIViewContentModeScaleAspectFit];
    pixelView.animationImages = self.pixelatedImagesArray;
    pixelView.animationDuration=0.700;
    pixelView.animationRepeatCount=1;
    pixelView.image = [self.pixelatedImagesArray lastObject];
    
//    CGAffineTransform translate = CGAffineTransformMakeTranslation(0.0, 0.0);
//    pixelView.transform = translate;
//    CGAffineTransform scale = CGAffineTransformScale(translate, 1.33, 1.33);
//    pixelView.transform = scale;
    pixelView.alpha = 1.0f;
    [pixelView startAnimating];
    
    self.pixelatedImageView = pixelView;
    [self.view insertSubview:self.pixelatedImageView aboveSubview:self.initialImageView];
    
    [self performSelector:@selector(startCanvasAnimations) withObject:nil afterDelay:0.200];
}


//- (void) lookupWarming {
//    UIImage *filteredimage;
//    NSString *filename = @"lookup_warming.png";
//    
//    GPUImagePicture *stillImageSource = [[GPUImagePicture alloc] initWithImage:self.imageView.image];
//    
//    GPUImagePicture *lookupImageSource = [[GPUImagePicture alloc] initWithImage:[UIImage imageNamed:filename]];
//    GPUImageLookupFilter *lookupFilter = [[GPUImageLookupFilter alloc] init];
//    [stillImageSource addTarget:lookupFilter];
//    [lookupImageSource addTarget:lookupFilter];
//    
//    [stillImageSource processImage];
//    [lookupImageSource processImage];
//    [lookupFilter ];
//    filteredimage = [lookupFilter imageFromCurrentlyProcessedOutput];
//    
//    NSDictionary *filteredDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:filteredimage, @"filteredImage", filename, @"filename", nil];
//    
//    [filterNames insertObject:filteredDictionary atIndex:0];
//    
//    [self lookupFilter2];
//}
//
//- (void) lookupFilter2 {
//    UIImage *filteredimage;
//    NSString *filename = @"lookup_filter2.png";
//    
//    GPUImagePicture *stillImageSource = [[GPUImagePicture alloc] initWithImage:self.imageView.image];
//    
//    GPUImagePicture *lookupImageSource = [[GPUImagePicture alloc] initWithImage:[UIImage imageNamed:filename]];
//    GPUImageLookupFilter *lookupFilter = [[GPUImageLookupFilter alloc] init];
//    [stillImageSource addTarget:lookupFilter];
//    [lookupImageSource addTarget:lookupFilter];
//    
//    [stillImageSource processImage];
//    [lookupImageSource processImage];
//    [lookupFilter imageFromCurrentlyProcessedOutput];
//    filteredimage = [lookupFilter imageFromCurrentlyProcessedOutput];
//    
//    NSDictionary *filteredDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:filteredimage, @"filteredImage", filename, @"filename", nil];
//    
//    [filterNames insertObject:filteredDictionary atIndex:0];
//    
//}


-(void)startCanvasAnimations
{
    
    self.facebookAnimationView.duration = 0.50;
    self.facebookAnimationView.delay    = 0.30;
    self.facebookAnimationView.type     = CSAnimationTypeBounceUp;
    
    self.twitterAnimationView.duration = 0.45;
    self.twitterAnimationView.delay    = 0.50;
    self.twitterAnimationView.type     = CSAnimationTypeBounceUp;
    
    self.checkmarkAnimationView.duration = 0.50;
    self.checkmarkAnimationView.delay    = 0.65;
    self.checkmarkAnimationView.type     = CSAnimationTypeBounceUp;
    
    self.cancelAnimationView.duration = 0.60;
    self.cancelAnimationView.delay    = 0.10;
    self.cancelAnimationView.type     = CSAnimationTypeBounceDown;
    
    [self.view startCanvasAnimation];
    
    self.twitterAnimationView.alpha = 1.0f;
    self.facebookAnimationView.alpha = 1.0f;
    self.checkmarkAnimationView.alpha = 1.0f;
    self.cancelAnimationView.alpha = 1.0f;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    self.pixelatedImagesArray = nil;

}


- (IBAction)facebookShare:(id)sender {
    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
    {
        SLComposeViewController *composeViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        
        [composeViewController addImage:self.pixelatedImageView.image];
        NSString *initalTextString = [NSString stringWithFormat:@"OMG, everything is pixelated! Check out this new app Bitpix and pixelate your life."];
        [composeViewController setInitialText:initalTextString];
        [self presentViewController:composeViewController animated:YES completion:nil];

    } else {
        [self showUnavailableAlertForServiceType:SLServiceTypeFacebook];
    }
    
}

- (IBAction)twitterShare:(id)sender {
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *composeViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        
        [composeViewController addImage:self.pixelatedImageView.image];
        NSString *initalTextString = [NSString stringWithFormat:@"OMG, everything is pixelated! Check out this new app Bitpix and pixelate your life. @bitpixapp"];
        [composeViewController setInitialText:initalTextString];
        [self presentViewController:composeViewController animated:YES completion:nil];
        
    } else {
        [self showUnavailableAlertForServiceType:SLServiceTypeTwitter];
    }
}



- (void)showUnavailableAlertForServiceType:(NSString *)serviceType
{
    NSString *serviceName = @"";
    
    if (serviceType == SLServiceTypeFacebook) {
        serviceName = @"Facebook";
    }
    else if (serviceType == SLServiceTypeTwitter) {
        serviceName = @"Twitter";
    }
    
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:@"Account"
                              message:[NSString stringWithFormat:@"Please go to the device settings and add a %@ account in order to share through that service", serviceName]
                              delegate:nil
                              cancelButtonTitle:@"Dismiss"
                              otherButtonTitles:nil];
    [alertView show];
}


- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (IBAction)savePicture:(id)sender {
    UIImageWriteToSavedPhotosAlbum(_pixelatedImageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
//    [self dismissViewControllerAnimated:NO completion:nil];
}

- (IBAction)cancel:(id)sender {
    
    self.pixelatedImagesArray = nil;
    NSLog(@"image array count = %u", self.pixelatedImagesArray.count);

    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{

    NSString *alertTitle;
    NSString *alertMessage;
    
    if(error)
    {
        alertTitle   = @"Error";
        alertMessage = @"Oh no! We were unable to save your BitPix photo. Please try again.";
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:alertTitle
                                                        message:alertMessage
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
        [alert show];

    }else
    {
        _saveButton.alpha =0.0f;
        [_saveButton setSelected:YES];
        _saveButton.userInteractionEnabled = NO;
        
        [_saveButton setImage:[UIImage imageNamed:@"ok.png"] forState:UIControlStateDisabled];
        [_saveButton setImage:[UIImage imageNamed:@"ok.png"] forState:UIControlStateSelected];
        [UIView animateWithDuration:0.300f animations:^{
            _saveButton.alpha =1.0f;
        }];
        
    }
    
}



@end
