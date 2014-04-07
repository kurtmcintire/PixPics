//
//  PreviewViewController.h
//  BitPix
//
//  Created by Matt Holmboe Kurt McIntire on 4/4/14.
//  Copyright (c) 2014 Vektor Digital. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PreviewViewController : UIViewController

@property (nonatomic, strong) UIImage *image;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
-(void)setImage:(UIImage *)profileImage;


@end
