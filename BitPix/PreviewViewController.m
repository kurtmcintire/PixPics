//
//  PreviewViewController.m
//  BitPix
//
//  Created by Matt Holmboe Kurt McIntire on 4/4/14.
//  Copyright (c) 2014 Vektor Digital. All rights reserved.
//

#import "PreviewViewController.h"

typedef enum SocialButtonTags
{
    SocialButtonTagFacebook,
    SocialButtonTagTwitter,
    
} SocialButtonTags;

@interface PreviewViewController ()
@property (weak, nonatomic) IBOutlet CSAnimationView *facebookAnimationView;
@property (weak, nonatomic) IBOutlet CSAnimationView *twitterAnimationView;
@property (weak, nonatomic) IBOutlet CSAnimationView *checkmarkAnimationView;
@property (nonatomic, strong) NSMutableArray *pixelatedImagesArray;
@property (nonatomic, strong) UIImageView *pixelatedImageView;


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
    [super viewWillAppear:YES];
     
     [_imageView setImage:_image];

    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
        if([UIScreen mainScreen].bounds.size.height == 568.0)
        {
            CGAffineTransform translate = CGAffineTransformMakeTranslation(-105, -190);
            self.imageView.transform =  translate;

            [UIView animateWithDuration:.0001 animations:^{
                self.imageView.transform =  translate;
            }
                             completion:^(BOOL finished){
                                 [UIView animateWithDuration:.0001 animations:^{
                                     self.imageView.transform = CGAffineTransformScale(translate, 1.333, 1.3333);
                                 }];
                             }];
        }
    }
    
    [self.cancelButton setStyle:kFRDLivelyButtonStyleCircleClose animated:YES];
    [self.cancelButton setOptions:@{kFRDLivelyButtonLineWidth: @(4.0f), kFRDLivelyButtonColor: [UIColor whiteColor]}];
    
    self.facebookAnimationView.alpha = 0.0f;
    self.twitterAnimationView.alpha = 0.0f;
    self.checkmarkAnimationView.alpha = 0.0f;
    
    [self performSelector:@selector(setupDisplayFiltering) withObject:nil afterDelay:0.25f];

}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    
    self.twitterAnimationView.alpha = 1.0f;
    self.facebookAnimationView.alpha = 1.0f;
    self.checkmarkAnimationView.alpha = 1.0f;
    
    self.pixelatedImagesArray = [@[] mutableCopy];
//    [self setupDisplayFiltering];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [self.cancelButton setStyle:kFRDLivelyButtonStyleClose animated:YES];
}


- (void)setupDisplayFiltering;
{
    CGRect originalRect = self.view.bounds;
    
    // screenshot of background image view
    UIImage * capturedImage = nil;
    if ([[UIScreen mainScreen] scale] == 2.0) {
        UIGraphicsBeginImageContextWithOptions(originalRect.size, NO, 1.33);
    } else {
        UIGraphicsBeginImageContext(originalRect.size);
    }
    CGContextRef cgContext = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(cgContext, kCGInterpolationDefault);
    [[self.imageView layer] renderInContext:cgContext];
    capturedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // build an array of images at different filter levels
    GPUImagePixellateFilter *pixellateFilter = [[GPUImagePixellateFilter alloc] init];
    for (NSInteger index = 1; index < 20; index++){
        pixellateFilter.fractionalWidthOfAPixel = index*0.00075;
        UIImage * filteredImage = [pixellateFilter imageByFilteringImage:capturedImage];
        [self.pixelatedImagesArray addObject:filteredImage];
    }
    
    [self showPixellatedImageView];
}


- (void) showPixellatedImageView {
    
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
        if([UIScreen mainScreen].bounds.size.height == 568.0)
        {
            CGAffineTransform translate = CGAffineTransformMakeTranslation(0, 0);
            self.pixelatedImageView.transform =  translate;
            
            [UIView animateWithDuration:.0001 animations:^{
                self.pixelatedImageView.transform =  translate;
            }
                             completion:^(BOOL finished){
                                 [UIView animateWithDuration:.0001 animations:^{
                                     self.pixelatedImageView.transform = CGAffineTransformScale(translate, 1.333, 1.3333);
                                 }];
                             }];
        }
    }

    // create a UIImageView from the array of pixellated images, add to view
    UIImageView *pixelView = [[UIImageView alloc] initWithFrame:self.view.frame];
    pixelView.animationImages = self.pixelatedImagesArray;
    pixelView.animationDuration=0.5;
    pixelView.animationRepeatCount=1;
    pixelView.image = [self.pixelatedImagesArray lastObject];
    [pixelView startAnimating];
    
    
    self.pixelatedImageView = pixelView;
    [self.view insertSubview:self.pixelatedImageView aboveSubview:self.imageView];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)facebookShare:(id)sender {
    
    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
    {
        SLComposeViewController *composeViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        
        [composeViewController addImage:self.pixelatedImageView.image];
        NSString *initalTextString = [NSString stringWithFormat:@"I spent traveling miles."];
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
        NSString *initalTextString = [NSString stringWithFormat:@"I spent traveling miles."];
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
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (IBAction)cancel:(id)sender {
    
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{

    NSString *alertTitle;
    NSString *alertMessage;
    
    if(error)
    {
        alertTitle   = @"Error";
        alertMessage = @"Unable to save to photo album.";
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:alertTitle
                                                        message:alertMessage
                                                       delegate:self
                                              cancelButtonTitle:@"Okay"
                                              otherButtonTitles:nil];
        [alert show];

    }
    
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    
}



@end
