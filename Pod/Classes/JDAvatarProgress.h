//
//  JDAvatarProgress.h
//  JDAvatarProgress
//
//  Created by Juan Pedro Catalán on 16/10/15.
//  Copyright © 2015 Juanpe Catalán. All rights reserved.
//

#import <UIKit/UIKit.h>

extern const float JDAvatarDefaultProgressBarLineWidth;
extern const float JDAvatarDefaultBorderWidth;

typedef void (^JDAvatarCompletionBlock)(UIImage * image, NSError *err);

@interface JDAvatarProgress : UIImageView

// --------------------------------------------------------------
// Load avatar
// --------------------------------------------------------------
- (void) setImageWithURLString:(NSString *)urlString;
- (void) setImageWithURL:(NSURL *)urlImage;
- (void) setImageWithURL:(NSURL *)urlImage placeholder:(UIImage *)placeholder;
- (void) setImageWithURL:(NSURL *)urlImage placeholder:(UIImage *)placeholder completion:(JDAvatarCompletionBlock)completion;
- (void) setImageWithURL:(NSURL *)urlImage placeholder:(UIImage *)placeholder progressColor:(UIColor *)progressBarColor progressBarLineWidh:(float)width completion:(JDAvatarCompletionBlock)completion;
- (void) setImageWithURL:(NSURL *)urlImage placeholder:(UIImage *)placeholder progressColor:(UIColor *)progressBarColor progressBarLineWidh:(float)width borderWidth:(float)borderWidth borderColor:(UIColor *)color completion:(JDAvatarCompletionBlock)completion;

// --------------------------------------------------------------
// Customization Border
// --------------------------------------------------------------
@property (nonatomic, strong) UIColor * borderColor;
@property (nonatomic) float borderWidth;

- (void) addBorderWithColor:(UIColor *)color width:(float)width;

// --------------------------------------------------------------
// Customization Progress
// --------------------------------------------------------------
@property (nonatomic, strong) UIColor * progressBarColor;
@property (nonatomic) float progressBarLineWidth;

@end
