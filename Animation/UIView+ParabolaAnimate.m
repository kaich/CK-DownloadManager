//
//  UIView+ParabolaAnimate.m
//  aisiweb
//
//  Created by Mac on 14-7-11.
//  Copyright (c) 2014年 weiaipu. All rights reserved.
//

#import "UIView+ParabolaAnimate.h"
#import <objc/runtime.h>

static NSString * PlaceHolderView=nil;

@implementation UIView (ParabolaAnimate)

-(void) showAnimateWithWindowCoorditionPoint:(CGPoint)targetPoint needPlacehold:(BOOL)isNeed
{
    if(isNeed)
    {
        UIWindow * keyWindow=[UIApplication sharedApplication].keyWindow;
        
        UIImage * imgSnapShot=[self snapshot];
        UIImageView * ivSnapShot=[[UIImageView alloc] initWithImage:imgSnapShot];
        ivSnapShot.frame=self.frame;
        [keyWindow addSubview:ivSnapShot];
        
        UIView * placeHoldView=[self getPlaceHolderView];
        if(placeHoldView)
        {
            [placeHoldView removeFromSuperview];
        }
        [self setPlaceHolderView:ivSnapShot];
        
        [self showAnimateWithView:ivSnapShot WindowCoorditionPoint:targetPoint];
    }
    else
    {
        [self showAnimateWithView:self WindowCoorditionPoint:targetPoint];
    }
    
}

-(void) showAnimateWithView:(UIView*) targetView  WindowCoorditionPoint:(CGPoint ) targetPoint
{
    UIWindow * keyWindow=[UIApplication sharedApplication].keyWindow;
    UIView  * parentView=self.superview;
    
    CGPoint controlPoint1;
    CGPoint controlPoint2;
    CGPoint startPoint;
    CGPoint endPoint;
    
    
    if(targetView==self)
    {
        controlPoint1=targetView.center;
        controlPoint2=CGPointMake(targetView.center.x+20, targetView.center.y+50);
        startPoint=targetView.center;
        endPoint=[parentView convertPoint:targetPoint fromView:keyWindow];
    }
    else
    {
        controlPoint1=[keyWindow convertPoint:targetView.center fromView:parentView];
        controlPoint2=[keyWindow convertPoint:CGPointMake(targetView.center.x+20, targetView.center.y+50) fromView:parentView] ;
        startPoint=[keyWindow convertPoint:targetView.center fromView:parentView];
        endPoint=targetPoint;
    }
    
    
    CGMutablePathRef  path=CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, startPoint.x, startPoint.y);
    CGPathAddCurveToPoint(path, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, endPoint.x, endPoint.y);
    
    float duration=1;
    
    CAKeyframeAnimation *  positionAnimation =[CAKeyframeAnimation animationWithKeyPath:@"position"];
    positionAnimation.path=path;
    positionAnimation.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    CATransform3D  endTransform3d=CATransform3DMakeScale(0.05, 0.05, 1);
    endTransform3d= CATransform3DRotate(endTransform3d, M_PI/6.0, 0.2, 1, 1);
    CABasicAnimation * transformAnimation=[CABasicAnimation animationWithKeyPath:@"transform"];
    transformAnimation.fromValue=[NSValue valueWithCATransform3D:CATransform3DIdentity];
    transformAnimation.toValue=[NSValue valueWithCATransform3D:endTransform3d];
  
    
    CAAnimationGroup * animationGroup=[CAAnimationGroup animation];
    animationGroup.animations=@[positionAnimation,transformAnimation];
    animationGroup.duration=duration;
    animationGroup.delegate=self;
    
    
    targetView.center=targetPoint;
    targetView.layer.transform=endTransform3d;
    [targetView.layer addAnimation:animationGroup forKey:@"ParabolaAnimate animation"];
    
    CGPathRelease(path);
}


-(void) animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if(flag==YES)
    {
        UIView * placeHolder=[self getPlaceHolderView];
        if(placeHolder)
        {
            [placeHolder removeFromSuperview];
            [self setPlaceHolderView:nil];
        }
    }
}



-(void) setPlaceHolderView:(UIView*) theView
{
    objc_setAssociatedObject(self, &PlaceHolderView, theView, OBJC_ASSOCIATION_RETAIN);
}

-(UIView *) getPlaceHolderView
{
    return  objc_getAssociatedObject(self, &PlaceHolderView);
}

@end



@implementation UIView (Snapshot)

- (UIImage *)snapshotLegacy {
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, [[UIScreen mainScreen] scale]);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    [self.layer renderInContext:ctx];
    
    UIImage *shapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return shapshotImage;
}

- (UIImage *)screenshotModern {
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, [[UIScreen mainScreen] scale]);
    
    [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:NO];
    
    UIImage *shapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return shapshotImage;
}

- (UIImage *)snapshot {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        // About 1.8x faster ~50ms
        return [self screenshotModern];
    } else {
        // Slow ~90ms
        return [self snapshotLegacy];
    }
}

@end
