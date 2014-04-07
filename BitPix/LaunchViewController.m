//
//  LaunchViewController.m
//  BitPix
//
//  Created by Matt Holmboe Kurt McIntire on 4/4/14.
//  Copyright (c) 2014 Vektor Digital. All rights reserved.
//

#import "LaunchViewController.h"

@interface LaunchViewController ()

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
    _logoLabel.font = [UIFont fontWithName:@"Extrude" size:80];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
//    [self launchAnimation];
    [self performSelector:@selector(launchAnimation) withObject:nil afterDelay:2.0f];
}

- (void)launchAnimation {
    [self performSegueWithIdentifier:@"launchToCameraSegue" sender:self];
    
    
//    [UIView animateWithDuration:2
//                     animations:^{
//                         
//                     completion:^(BOOL finished) {
//                         [self performSegueWithIdentifier:@"launchToCameraSegue" sender:self];
//                     }
//     ];
}

@end
