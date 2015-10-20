//
//  JDViewController.m
//  JDAvatarProgress
//
//  Created by Juanpe on 10/20/2015.
//  Copyright (c) 2015 Juanpe. All rights reserved.
//

#import "JDViewController.h"
#import "JDAvatarProgress.h"

@interface JDViewController ()

@property (nonatomic, weak) IBOutlet JDAvatarProgress * avatarImgView;

@end

@implementation JDViewController

- (void)viewDidLoad
{
    [super viewDidLoad]; 
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) btnRefreshTouchUpInside:(id)sender{
    
    
    [self.avatarImgView setImageWithURL:[NSURL URLWithString:@"http://3.bp.blogspot.com/-k-0O0FocJ2I/TyWbextRGlI/AAAAAAAACqo/GuPx0RH7PcY/s1600/Fondo+Pantalla.jpg"]
                            placeholder:nil
                          progressColor:[UIColor orangeColor]
                    progressBarLineWidh:JDAvatarDefaultProgressBarLineWidth
                            borderWidth:JDAvatarDefaultBorderWidth
                            borderColor:nil
                             completion:^(UIImage * resultImage, NSError * error){
                                 
                                 NSLog(@"image => %@", resultImage);
                                 NSLog(@"error => %@", error);
                                 
                             }];
}

@end
