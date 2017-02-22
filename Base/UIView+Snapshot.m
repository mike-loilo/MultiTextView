//
//  UIView+Snapshot.m
//  LoiloPad
//
//  Created by Kiyotaka Sasaya on 2013/03/15.
//
//

#import "UIView+Snapshot.h"
#import <QuartzCore/CALayer.h>

@implementation UIView (Snapshot)

- (UIImage *)snapshot
{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    if ([self isKindOfClass:UIScrollView.class]) {
        UIScrollView *scrollView = (UIScrollView *)self;
        CGContextTranslateCTM(context, -scrollView.contentOffset.x, -scrollView.contentOffset.y);
        CGContextScaleCTM(context, scrollView.zoomScale, scrollView.zoomScale);
    }
    [self.layer renderInContext:context];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
