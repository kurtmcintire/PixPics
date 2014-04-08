//
//  PreviewViewController.m
//  BitPix
//
//  Created by Matt Holmboe Kurt McIntire on 4/4/14.
//  Copyright (c) 2014 Vektor Digital. All rights reserved.
//

#import "PreviewViewController.h"

@interface PreviewViewController ()
@property (weak, nonatomic) IBOutlet CSAnimationView *facebookAnimationView;
@property (weak, nonatomic) IBOutlet CSAnimationView *twitterAnimationView;

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
    
    [_imageView setImage:_image];
    
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
        if([UIScreen mainScreen].bounds.size.height == 568.0)
        {
            CGAffineTransform translate = CGAffineTransformMakeTranslation(-105, -190);
 
            [UIView animateWithDuration:.001 animations:^{
                self.imageView.transform =  translate;
            }
                             completion:^(BOOL finished){
                                 [UIView animateWithDuration:.001 animations:^{
                                     self.imageView.transform = CGAffineTransformScale(translate, 1.333, 1.3333);
                                 }];
                             }];
        }
    }
    
    [self.cancelButton setStyle:kFRDLivelyButtonStyleCircleClose animated:YES];
    [self.cancelButton setOptions:@{kFRDLivelyButtonLineWidth: @(4.0f), kFRDLivelyButtonColor: [UIColor whiteColor]}];
    
    self.facebookAnimationView.alpha=0.0f;
    self.twitterAnimationView.alpha=0.0f;

}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.twitterAnimationView.alpha=1.0f;
    self.facebookAnimationView.alpha=1.0f;

//    [self.twitterAnimationView startCanvasAnimation];
//    [self.facebookAnimationView startCanvasAnimation];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    

    [[UIApplication sharedApplication] setStatusBarHidden:YES];

    [self.cancelButton setStyle:kFRDLivelyButtonStyleClose animated:YES];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)cancel:(id)sender {
    
    [self dismissViewControllerAnimated:NO completion:nil];
}
@end
