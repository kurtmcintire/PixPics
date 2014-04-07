//
//  PreviewViewController.m
//  BitPix
//
//  Created by Matt Holmboe Kurt McIntire on 4/4/14.
//  Copyright (c) 2014 Vektor Digital. All rights reserved.
//

#import "PreviewViewController.h"

@interface PreviewViewController ()

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
    
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
        [_imageView setImage:_image];
    
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
