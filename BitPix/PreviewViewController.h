//
//  PreviewViewController.h
//  BitPix
//
//  Created by Matt Holmboe Kurt McIntire on 4/4/14.
//  Copyright (c) 2014 Vektor Digital. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FRDLivelyButton.h"
#import <Canvas/CSAnimation.h>
#import <Canvas/CSAnimationView.h>
#import "GPUImage.h"
#import  <CoreGraphics/CoreGraphics.h>
#import <Social/Social.h>

@interface PreviewViewController : UIViewController


@property (nonatomic, strong) UIImage *image;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet FRDLivelyButton *cancelButton;

- (IBAction)facebookShare:(id)sender;
- (IBAction)twitterShare:(id)sender;

- (IBAction)savePicture:(id)sender;
- (IBAction)cancel:(id)sender;

@end
