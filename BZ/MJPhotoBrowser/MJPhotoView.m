//
//  MJZoomingScrollView.m
//
//  Created by mj on 13-3-4.
//  Copyright (c) 2013年 itcast. All rights reserved.
//

#import "MJPhotoView.h"
#import "MJPhoto.h"
#import "MJPhotoLoadingView.h"
#import "UIImageView+WebCache.h"
#import <QuartzCore/QuartzCore.h>

@interface MJPhotoView ()
{
    BOOL _doubleTap;
    UIImageView *_imageView;
}

@property (nonatomic, strong) UIActivityIndicatorView *imageLoadingIndicator;

@end

@implementation MJPhotoView

- (id)initWithFrame:(CGRect)frame {
    
    if ((self = [super initWithFrame:frame])) {
        self.clipsToBounds = YES;
		// 图片
		_imageView = [[UIImageView alloc] init];
		_imageView.contentMode = UIViewContentModeScaleAspectFit;
		[self addSubview:_imageView];
		
		// 属性
		self.backgroundColor = [UIColor clearColor];
		self.delegate = self;
		self.showsHorizontalScrollIndicator = NO;
		self.showsVerticalScrollIndicator = NO;
		self.decelerationRate = UIScrollViewDecelerationRateFast;
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        // 监听点击
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        singleTap.delaysTouchesBegan = YES;
        singleTap.numberOfTapsRequired = 1;
        [self addGestureRecognizer:singleTap];
        
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
        doubleTap.numberOfTapsRequired = 2;
        [self addGestureRecognizer:doubleTap];
    }
    return self;
}

#pragma mark - photoSetter
- (void)setPhoto:(MJPhoto *)photo {
    _photo = photo;
    
    [self showImage];
}

#pragma mark 显示图片
- (void)showImage {
    
    if ([self.imageLoadingIndicator isAnimating]) {
        [self.imageLoadingIndicator stopAnimating];
    }
    
    if (_photo.firstShow) {
        _imageView.image = self.photo.placeholder;
        
        if (![_photo.url.absoluteString hasSuffix:@"gif"]) {
            
            if (![self.imageLoadingIndicator isAnimating]) {
                
                [self.imageLoadingIndicator startAnimating];
            }
            [_imageView sd_setImageWithURL:_photo.url placeholderImage:self.photo.placeholder completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                self.photo.image = image;
                [self.imageLoadingIndicator stopAnimating];
                [self adjustFrame];
 
            }];
        }
    } else {
        [self photoStartLoad];
    }
    [self adjustFrame];
}

#pragma mark 开始加载图片
- (void)photoStartLoad {
    
    if (_photo.image) {
        self.scrollEnabled = YES;
        _imageView.image = _photo.image;
        [self photoDidFinishLoadWithImage:_photo.image];
    } else {
        self.scrollEnabled = NO;
        __unsafe_unretained MJPhotoView *photoView = self;

        [_imageView sd_setImageWithURL:_photo.url placeholderImage:self.photo.placeholder options:SDWebImageRetryFailed|SDWebImageLowPriority progress:^(NSInteger receivedSize, NSInteger expectedSize) {
          
            if (![self.imageLoadingIndicator isAnimating]) {
                
                [self.imageLoadingIndicator startAnimating];
            }
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            [self.imageLoadingIndicator stopAnimating];
            [photoView photoDidFinishLoadWithImage:image];
        }];
    }
}

#pragma mark 加载完毕
- (void)photoDidFinishLoadWithImage:(UIImage *)image
{
    if (image) {
        self.scrollEnabled = YES;
        _photo.image = image;
        
        if ([self.photoViewDelegate respondsToSelector:@selector(photoViewImageFinishLoad:)]) {
            [self.photoViewDelegate photoViewImageFinishLoad:self];
        }
    }
    [self adjustFrame];
}
#pragma mark 调整frame
- (void)adjustFrame {
    
	if (_imageView.image == nil) return;
    
    CGSize boundsSize = self.bounds.size;
    CGFloat boundsWidth = boundsSize.width;
    CGFloat boundsHeight = boundsSize.height;
    
    CGSize imageSize = _imageView.image.size;
    CGFloat imageWidth = imageSize.width;
    CGFloat imageHeight = imageSize.height;
	
    CGFloat minScale = boundsWidth / imageWidth;
	if (minScale > 1) {
		minScale = 1.0;
	}
	CGFloat maxScale = 1.5;
	if ([UIScreen instancesRespondToSelector:@selector(scale)]) {
		maxScale = maxScale / [[UIScreen mainScreen] scale];
	}
	self.maximumZoomScale = maxScale;
	self.minimumZoomScale = minScale;
	self.zoomScale = minScale;
    
    CGRect imageFrame = CGRectMake(0, 0, boundsWidth, imageHeight * boundsWidth / imageWidth);
    
    self.contentSize = CGSizeMake(0, imageFrame.size.height);
    
    if (imageFrame.size.height < boundsHeight) {
        imageFrame.origin.y = floorf((boundsHeight - imageFrame.size.height) / 2.0);
	} else {
        imageFrame.origin.y = 0;
	}
    
    if (_photo.firstShow) {
        _photo.firstShow = NO;
        _imageView.frame = [_photo.srcImageView convertRect:_photo.srcImageView.bounds toView:nil];
        
        [UIView animateWithDuration:0.3 animations:^{
             [UIApplication sharedApplication].keyWindow.rootViewController.view.transform = CGAffineTransformMakeScale(1.0, 1.0);
            _imageView.frame = imageFrame;
        } completion:^(BOOL finished) {
            _photo.srcImageView.image = _photo.placeholder;
            [self photoStartLoad];
        }];
    } else {
        _imageView.frame = imageFrame;
    }
}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
	return _imageView;
}

#pragma mark - 手势处理
- (void)handleSingleTap:(UITapGestureRecognizer *)tap {
    _doubleTap = NO;
    [self performSelector:@selector(hide) withObject:nil afterDelay:0.2];
}

- (void)hide {
    
    if (_doubleTap) return;
    [self.imageLoadingIndicator removeFromSuperview];
    self.contentOffset = CGPointZero;
    
    CGFloat duration = 0.15;
    if (_photo.srcImageView.clipsToBounds) {
        [self performSelector:@selector(reset) withObject:nil afterDelay:duration];
    }
    
    [UIView animateWithDuration:duration + 0.1 animations:^{
        
        [UIApplication sharedApplication].keyWindow.rootViewController.view.transform =  CGAffineTransformIdentity;
        
        _imageView.frame = [_photo.srcImageView convertRect:_photo.srcImageView.bounds toView:nil];
        
        // gif图片仅显示第0张
        if (_imageView.image.images) {
            _imageView.image = _imageView.image.images[0];
        }
        
        // 通知代理
        if ([self.photoViewDelegate respondsToSelector:@selector(photoViewSingleTap:)]) {
            [self.photoViewDelegate photoViewSingleTap:self];
        }
    } completion:^(BOOL finished) {
        // 设置底部的小图片
        _photo.srcImageView.image = _photo.placeholder;
        
        // 通知代理
        if ([self.photoViewDelegate respondsToSelector:@selector(photoViewDidEndZoom:)]) {
            [self.photoViewDelegate photoViewDidEndZoom:self];
        }
    }];
}

- (void)reset {
    
    _imageView.image = _photo.capture;
    _imageView.contentMode = UIViewContentModeScaleToFill;
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)tap {
    _doubleTap = YES;
    
    CGPoint touchPoint = [tap locationInView:self];
	if (self.zoomScale == self.maximumZoomScale) {
		[self setZoomScale:self.minimumZoomScale animated:YES];
	} else {
		[self zoomToRect:CGRectMake(touchPoint.x, touchPoint.y, 1, 1) animated:YES];
	}
}

- (UIActivityIndicatorView *)imageLoadingIndicator {
    if (_imageLoadingIndicator == nil) {
        _imageLoadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _imageLoadingIndicator.center = [UIApplication sharedApplication].keyWindow.center;
        _imageLoadingIndicator.hidesWhenStopped = YES;
        _imageLoadingIndicator.hidden = NO;
        _imageLoadingIndicator.tag = 666;
        [[UIApplication sharedApplication].keyWindow addSubview:_imageLoadingIndicator];
    }
    [[UIApplication sharedApplication].keyWindow bringSubviewToFront:_imageLoadingIndicator];
    return _imageLoadingIndicator;
}

- (void)dealloc {
    
    [_imageView sd_setImageWithURL:[NSURL URLWithString:@"file:///abc"]];
    [self.imageLoadingIndicator removeFromSuperview];
}
@end
