//
//  JDAvatarProgress.m
//  JDAvatarProgress
//
//  Created by Juan Pedro Catalán on 16/10/15.
//  Copyright © 2015 Juanpe Catalán. All rights reserved.
//

#import "JDAvatarProgress.h"
#import <QuartzCore/QuartzCore.h>

const float JDAvatarDefaultProgressBarLineWidth = 10.0f;
const float JDAvatarDefaultBorderWidth = 5.0f;


@interface JDAvatarProgress () <NSURLSessionDelegate>

@property (nonatomic, strong) NSURLSession * urlSession;
@property (nonatomic, strong) NSURLSessionDownloadTask * downloadTask;

@property (nonatomic, strong) UIImage * placeholderImage;
@property (nonatomic, strong) CAShapeLayer *spinLayer;
@property (nonatomic) float progress;
@property (nonatomic) float tickness;

@property (nonatomic, copy) JDAvatarCompletionBlock completionBlock;

@end

@implementation JDAvatarProgress

- (void) awakeFromNib{
    
    [self _commonInit];
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bounds = [self bounds];
    
    CGRect outer = CGRectInset([self bounds], self.tickness/2.0f, self.tickness/2.0f);
    
    UIBezierPath * outerPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(CGRectGetMidX(outer), CGRectGetMidY(outer))
                                                              radius:[self _radius]
                                                          startAngle:-M_PI_2 endAngle:(2.0 * M_PI - M_PI_2) clockwise:YES];
    
    [[self spinLayer] setPath:[outerPath CGPath]];
    [[self spinLayer] setFrame:bounds];
    
    UIGraphicsBeginImageContextWithOptions(bounds.size, NO, [[UIScreen mainScreen] scale]);
    
    UIGraphicsEndImageContext();
}

- (NSURLSession *) urlSession {

    if (!_urlSession) {
        
        _urlSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                                        delegate:self
                                                   delegateQueue:[NSOperationQueue mainQueue]];
    }
    
    return _urlSession;
}

- (void) setPlaceholderImage:(UIImage *)placeholderImage{
    
    _placeholderImage = placeholderImage;
    
    self.image = _placeholderImage;
}

- (void) setProgressBarColor:(UIColor *)progressBarColor{

    _progressBarColor = progressBarColor;
    
    [self setNeedsLayout];
}

- (void) setProgressBarLineWidth:(float)progressBarLineWidth{
    
    _progressBarLineWidth = progressBarLineWidth + self.borderWidth;
    
    [self setNeedsLayout];
}

- (void) setBorderColor:(UIColor *)borderColor{
    
    _borderColor = borderColor;
    
    [self _drawBorder];
}

- (void) setBorderWidth:(float)borderWidth{
    
    _borderWidth = borderWidth;
    
    self.progressBarLineWidth = self.progressBarLineWidth;
    
    [self _drawBorder];
}

- (void) addBorderWithColor:(UIColor *)color width:(float)width{

    if (color) {
        self.borderColor = color;
    }
    
    self.borderWidth = width;
}

#pragma mark - Setters -

- (void) setImageWithURLString:(NSString *)urlString{
    [self setImageWithURL:[NSURL URLWithString:urlString] placeholder:nil progressColor:nil progressBarLineWidh:self.progressBarLineWidth borderWidth:self.borderWidth borderColor:nil completion:nil];
}

- (void) setImageWithURL:(NSURL *)urlImage{
    [self setImageWithURL:urlImage placeholder:nil progressColor:nil progressBarLineWidh:self.progressBarLineWidth borderWidth:self.borderWidth borderColor:nil completion:nil];
}

- (void) setImageWithURL:(NSURL *)urlImage placeholder:(UIImage *)placeholder{
    [self setImageWithURL:urlImage placeholder:placeholder progressColor:nil progressBarLineWidh:self.progressBarLineWidth borderWidth:self.borderWidth borderColor:nil completion:nil];
}

- (void) setImageWithURL:(NSURL *)urlImage placeholder:(UIImage *)placeholder completion:(JDAvatarCompletionBlock)completion{
    [self setImageWithURL:urlImage placeholder:placeholder progressColor:nil progressBarLineWidh:self.progressBarLineWidth borderWidth:self.borderWidth borderColor:nil completion:completion];
}

- (void) setImageWithURL:(NSURL *)urlImage placeholder:(UIImage *)placeholder progressColor:(UIColor *)progressBarColor progressBarLineWidh:(float)width completion:(JDAvatarCompletionBlock)completion{
    [self setImageWithURL:urlImage placeholder:placeholder progressColor:progressBarColor progressBarLineWidh:width borderWidth:self.borderWidth borderColor:nil completion:completion];
}

- (void) setImageWithURL:(NSURL *)urlImage placeholder:(UIImage *)placeholder progressColor:(UIColor *)progressBarColor progressBarLineWidh:(float)width borderWidth:(float)borderWidth borderColor:(UIColor *)color completion:(JDAvatarCompletionBlock)completion{

    if (self.downloadTask && self.downloadTask.state == NSURLSessionTaskStateRunning) {
        
        __weak typeof(self) weakSelf = self;
        
        [self _dismissProgressBar];
        
        [self.downloadTask cancelByProducingResumeData:^(NSData * currentData){
            
            weakSelf.downloadTask = nil;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf setImageWithURL:urlImage placeholder:placeholder progressColor:progressBarColor progressBarLineWidh:width borderWidth:borderWidth borderColor:color completion:completion];
            });
        }];
        
        
    }else{
        
        if (placeholder) {
            self.placeholderImage = placeholder;
        }
        
        if (completion) {
            self.completionBlock = completion;
        }
        
        self.progressBarLineWidth = width;
        
        if (progressBarColor) {
            self.progressBarColor = progressBarColor;
        }
        
        self.borderWidth = borderWidth;
        
        if (color) {
            self.borderColor = color;
        }
        
        self.progress = 0.0f;
        
        [self _initalizateProgressBar];
        
        self.downloadTask = [self.urlSession downloadTaskWithURL:urlImage];
        [self.downloadTask resume];
    }
}

#pragma mark - NSURLSession Delegate Methods -

- (void) URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if (error) {
        
        __weak typeof(self) weakSelf = self;
        
        dispatch_async(dispatch_get_main_queue(), ^{

            if(task.state != NSURLSessionTaskStateCompleted){
                [weakSelf _dismissProgressBar];
            }
            
            if (weakSelf.completionBlock) {
                weakSelf.completionBlock(nil, error);
            }
            
        });
    }
}

- (void) URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    __weak typeof(self) weakSelf = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        double value = (double)totalBytesWritten/(double)totalBytesExpectedToWrite;
        [weakSelf _setProgress:value
                      animated:YES];
    });
}

- (void) URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    NSData * data = [NSData dataWithContentsOfURL:location];
    UIImage * imageObtained = [UIImage imageWithData:data];
    
    __weak typeof(self) weakSelf = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [weakSelf _setProgress:1.0f animated:NO];
        [weakSelf _dismissProgressBar];
        
        [UIView transitionWithView:self
                          duration:0.3f
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            
                            weakSelf.image = imageObtained;
                            
                        } completion:^(BOOL finished) {
                            
                        }];
        
        if (weakSelf.completionBlock) {
            weakSelf.completionBlock(imageObtained, nil);
        }
        
    });
}

#pragma mark - Private Methods -

- (void) _dismissProgressBar{
    
    [self.spinLayer removeFromSuperlayer];
    self.spinLayer = nil;
}

- (float) _radius
{
    CGRect r = CGRectInset([self bounds], self.tickness/2.0, self.tickness/2.0);
    float w = r.size.width;
    float h = r.size.height;
    if(w > h)
        return h / 2.0;
    
    return w / 2.0;
}

- (void) _setProgress:(float)progress animated:(BOOL)animated{
    
    float currentProgress = _progress;
    _progress = progress;
    
    [CATransaction begin];
    if(animated) {
        float delta = fabs(_progress - currentProgress);
        [CATransaction setAnimationDuration:MAX(0.2, delta * 1.0)];
    } else {
        [CATransaction setDisableActions:YES];
    }
    [[self spinLayer] setStrokeEnd:_progress];
    [CATransaction commit];
}

- (void) _commonInit{
    
    self.layer.cornerRadius = CGRectGetWidth(self.frame)/2;
    self.layer.masksToBounds = YES;
    
    // Default values
    self.progressBarColor = [UIColor greenColor];
    self.progressBarLineWidth = JDAvatarDefaultProgressBarLineWidth;
    self.tickness = 1.0f;
    
    self.borderColor = [UIColor colorWithWhite:0.9f
                                         alpha:1.0f];
    self.borderWidth = JDAvatarDefaultBorderWidth;
}

- (void) _drawBorder{

    self.layer.borderColor = self.borderColor.CGColor;
    self.layer.borderWidth = self.borderWidth;
    
    [self setNeedsDisplay];
}

- (void) _initalizateProgressBar{
        
    if (self.spinLayer) {
        [self _dismissProgressBar];
    }
    
    self.spinLayer = [CAShapeLayer layer];
    
    self.spinLayer.lineCap      = @"round";
    self.spinLayer.strokeColor  = self.progressBarColor.CGColor;
    self.spinLayer.fillColor    = [UIColor clearColor].CGColor;
    self.spinLayer.lineWidth    = self.progressBarLineWidth;
    self.spinLayer.strokeEnd    = _progress;
    
    [self.layer addSublayer:self.spinLayer];
}

@end
