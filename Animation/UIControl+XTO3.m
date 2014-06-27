//
//  UIButton+XTO3.m
//  aisiweb
//
//  Created by Mac on 14-6-25.
//  Copyright (c) 2014年 weiaipu. All rights reserved.
//

#import "UIControl+XTO3.h"
#import <objc/runtime.h>

static NSString * LineImage =nil;
static NSString * FirstLine =nil;
static NSString * SecondLine =nil;
static NSString * ThirdLine =nil;

static NSString * IsXMode=nil;

float pad=5;
float margin=4;
float space=3;


@implementation UIControl (XTO3)
@dynamic lineImage,isXMode;


-(void) showAnimateButton
{
    [self setIsXMode:NO];
    
    space=(self.frame.size.height-2*pad-3*[self lineHeight])/2.f;
    
    float lineWidth=[self lineWidth];
    float lineHeight=[self lineHeight];
    
    UIImageView * firstLine=[[UIImageView alloc] initWithFrame:CGRectMake(margin, pad, lineWidth, lineHeight)];
    [firstLine setImage:self.lineImage];
    [self addSubview:firstLine];
    [self setFirstLine:firstLine];
    [self addSubview:firstLine];
    
    UIImageView * secondLine=[[UIImageView alloc] initWithFrame:CGRectMake(margin, pad+space+lineHeight, lineWidth, lineHeight)];
    [secondLine setImage:self.lineImage];
    [self addSubview:secondLine];
    [self setSecondLine:secondLine];
    [self addSubview:secondLine];
    
    UIImageView * thirdLine=[[UIImageView alloc] initWithFrame:CGRectMake(margin, pad+space*2+lineHeight*2, lineWidth, lineHeight)];
    [thirdLine setImage:self.lineImage];
    [self addSubview:thirdLine];
    [self setThirdLine:thirdLine];
    [self addSubview:thirdLine];
    
    [self addTarget:self action:@selector(clickButton) forControlEvents:UIControlEventTouchUpInside];
}


#pragma mark - config UI
-(float) lineHeight
{
    float lineHeight=self.lineImage.size.height;
    return lineHeight;
}


-(float) lineWidth
{
    float lineWidth=self.frame.size.width-2*margin;
    return lineWidth;
}


-(float) firstLineHorizonizedCenterY
{
    return pad+[self lineHeight]/2.f;
}

-(float) thirdLineHorizonizedCenterY
{
    return  pad+space*2+[self lineHeight]*2+[self lineHeight]/2.f;
}


#pragma mark - private method
#define transformRotate(angle) [NSValue valueWithCATransform3D:CATransform3DMakeAffineTransform(CGAffineTransformMakeRotation(angle/180.f*M_PI))]



-(void) clickButton
{
    [self setIsXMode:!self.isXMode];

    if(self.isXMode)
    {
        [self change3ToXAnimation];
    }
    else
    {
        [self changeXTo3Animation];
    }
    
    
}


-(void) change3ToXAnimation
{
    [self firstline].center=[self ownCenter];
    [self thirdLine].center=[self ownCenter];
    
    CAKeyframeAnimation * animationFirst=[self animationWithValues:@[transformRotate(60.f),transformRotate(40.f),transformRotate(45.f)] times:@[@(0.5f), @(0.8f),@(1.0)] duration:0.3];
    [[self firstline].layer addAnimation:animationFirst forKey:@"Button3TOXFirst"];
    
    [self animateWithView:[self secondLine] alpha:0];
    
    CAKeyframeAnimation * animationThird=[self animationWithValues:@[transformRotate(-60.f),transformRotate(-40.f),transformRotate(-45.f)] times:@[@(0.5f), @(0.8f),@(1.0)] duration:0.3];
    [[self thirdLine].layer addAnimation:animationThird forKey:@"Button3TOXThird"];
    
}


-(void) changeXTo3Animation
{
    [self firstline].center=CGPointMake([self firstline].center.x, [self firstLineHorizonizedCenterY]);
    [self thirdLine].center=CGPointMake([self thirdLine].center.x, [self thirdLineHorizonizedCenterY]);
    
    CAKeyframeAnimation * animationFirst=[self animationWithValues:@[transformRotate(-10),transformRotate(5),transformRotate(0)] times:@[@(0.5f), @(0.8f),@(1.0)] duration:0.3];
    [[self firstline].layer addAnimation:animationFirst forKey:@"ButtonXTO3First"];
    
    [self animateWithView:[self secondLine] alpha:1];
    
    CAKeyframeAnimation * animationThird=[self animationWithValues:@[transformRotate(10),transformRotate(-5),transformRotate(0)] times:@[@(0.5f), @(0.8f),@(1.0)] duration:0.3];
    [[self thirdLine].layer addAnimation:animationThird forKey:@"ButtonXTO3Third"];
}


-(void) animateWithView:(UIView *) theView  alpha:(float) alpha
{
    [UIView animateWithDuration:0.3 animations:^{
        theView.alpha=alpha;
    }];
}


-(CGPoint) ownCenter
{
    return CGPointMake(self.frame.size.width/2.f, self.frame.size.height/2.f);
}

- (CAKeyframeAnimation *)animationWithValues:(NSArray*)values times:(NSArray*)times duration:(CGFloat)duration {
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    [animation setValues:values];
    [animation setKeyTimes:times];
    [animation setFillMode:kCAFillModeForwards];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    [animation setRemovedOnCompletion:NO];
    [animation setDuration:duration];
    
    return animation;
}

#pragma mark - dynamic
-(void) setLineImage:(UIImage *)lineImage
{
    objc_setAssociatedObject(self, &LineImage, lineImage, OBJC_ASSOCIATION_RETAIN);
}

-(UIImage *) lineImage
{
    return  objc_getAssociatedObject(self, &LineImage);
}


-(void) setFirstLine:(UIImageView *)firstLine
{
    objc_setAssociatedObject(self, &FirstLine, firstLine, OBJC_ASSOCIATION_RETAIN);
}

-(UIImageView *) firstline
{
    return  objc_getAssociatedObject(self, &FirstLine);
}


-(void) setSecondLine:(UIImageView *)secondLine
{
    objc_setAssociatedObject(self, &SecondLine, secondLine, OBJC_ASSOCIATION_RETAIN);
}

-(UIImageView *) secondLine
{
    return  objc_getAssociatedObject(self, &SecondLine);
}



-(void) setThirdLine:(UIImageView *)thirdLine
{
    objc_setAssociatedObject(self, &ThirdLine, thirdLine, OBJC_ASSOCIATION_RETAIN);
}

-(UIImageView *) thirdLine
{
    return  objc_getAssociatedObject(self, &ThirdLine);
}


-(void) setIsXMode:(BOOL)isXMode
{
    NSNumber * value=[NSNumber numberWithBool:isXMode];
    objc_setAssociatedObject(self, &IsXMode, value, OBJC_ASSOCIATION_ASSIGN);
}

-(BOOL) isXMode
{
    NSNumber * value=objc_getAssociatedObject(self, &IsXMode);
    return [value boolValue];
}

@end
