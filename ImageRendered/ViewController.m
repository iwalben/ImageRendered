//
//  ViewController.m
//  ImageRendered
//
//  Created by walben on 2019/11/7.
//  Copyright © 2019 LB. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()

@property (nonatomic ,strong) UIImageView * imageView;

@end

@implementation ViewController
{
    CGRect _imageViewRect;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self.view addSubview:self.imageView];
    
    _imageViewRect = self.imageView.bounds;
    
}

-(void)method_1
{
    self.imageView.image = [UIImage imageNamed:@"VIIRS"];
}

-(void)method_2
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        UIImage * image = [self resiezedImage:@"VIIRS" Size:self->_imageViewRect.size];
        
        //UIImage * image = [self decodedImageWithImage:[UIImage imageNamed:@"VIIRS"]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [UIView transitionWithView:self.imageView duration:1.0 options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionTransitionCrossDissolve  animations:^{
                
                self.imageView.image = image ;
                
            } completion:^(BOOL finished) {
                
            }];
            
        });
    });
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    //[self method_1];   //内存暴涨
    [self method_2];     //内存没有明显变化
}

-(UIImage *)resiezedImage:(NSString *)imageName Size:(CGSize)size
{
    UIImage *image = [UIImage imageNamed:imageName];
    
    UIGraphicsImageRenderer * render = [[UIGraphicsImageRenderer alloc] initWithSize:size];
    
    return [render imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull rendererContext) {
        
        CGRect rect = AVMakeRectWithAspectRatioInsideRect(image.size, self->_imageViewRect);
        
        [image drawInRect:rect];
    }];
}

-(UIImageView *)imageView
{
    if (!_imageView) {
        
        _imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 250, 250)];
        
        _imageView.center = self.view.center ;
        
        _imageView.backgroundColor = [UIColor orangeColor];
    }
    
    return _imageView ;
}


//source code of SD
- (UIImage *)decodedImageWithImage:(UIImage *)image {
    // while downloading huge amount of images
    // autorelease the bitmap context
    // and all vars to help system to free memory
    // when there are memory warning.
    // on iOS7, do not forget to call
    // [[SDImageCache sharedImageCache] clearMemory];
    
    if (image == nil) { // Prevent "CGBitmapContextCreateImage: invalid context 0x0" error
        return nil;
    }
    
    @autoreleasepool{
        // do not decode animated images
        if (image.images != nil) {
            return image;
        }
        
        CGImageRef imageRef = image.CGImage;
        
        CGImageAlphaInfo alpha = CGImageGetAlphaInfo(imageRef);
        BOOL anyAlpha = (alpha == kCGImageAlphaFirst ||
                         alpha == kCGImageAlphaLast ||
                         alpha == kCGImageAlphaPremultipliedFirst ||
                         alpha == kCGImageAlphaPremultipliedLast);
        if (anyAlpha) {
            return image;
        }
        
        // current
        CGColorSpaceModel imageColorSpaceModel = CGColorSpaceGetModel(CGImageGetColorSpace(imageRef));
        CGColorSpaceRef colorspaceRef = CGImageGetColorSpace(imageRef);
        
        BOOL unsupportedColorSpace = (imageColorSpaceModel == kCGColorSpaceModelUnknown ||
                                      imageColorSpaceModel == kCGColorSpaceModelMonochrome ||
                                      imageColorSpaceModel == kCGColorSpaceModelCMYK ||
                                      imageColorSpaceModel == kCGColorSpaceModelIndexed);
        if (unsupportedColorSpace) {
            colorspaceRef = CGColorSpaceCreateDeviceRGB();
        }
        
        size_t width = CGImageGetWidth(imageRef);
        size_t height = CGImageGetHeight(imageRef);
        NSUInteger bytesPerPixel = 4;
        NSUInteger bytesPerRow = bytesPerPixel * width;
        NSUInteger bitsPerComponent = 8;
        
        
        // kCGImageAlphaNone is not supported in CGBitmapContextCreate.
        // Since the original image here has no alpha info, use kCGImageAlphaNoneSkipLast
        // to create bitmap graphics contexts without alpha info.
        CGContextRef context = CGBitmapContextCreate(NULL,
                                                     width,
                                                     height,
                                                     bitsPerComponent,
                                                     bytesPerRow,
                                                     colorspaceRef,
                                                     kCGBitmapByteOrderDefault|kCGImageAlphaNoneSkipLast);
        
        // Draw the image into the context and retrieve the new bitmap image without alpha
        CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
        CGImageRef imageRefWithoutAlpha = CGBitmapContextCreateImage(context);
        UIImage *imageWithoutAlpha = [UIImage imageWithCGImage:imageRefWithoutAlpha
                                                         scale:image.scale
                                                   orientation:image.imageOrientation];
        
        if (unsupportedColorSpace) {
            CGColorSpaceRelease(colorspaceRef);
        }
        
        CGContextRelease(context);
        CGImageRelease(imageRefWithoutAlpha);
        
        return imageWithoutAlpha;
    }
}


@end
