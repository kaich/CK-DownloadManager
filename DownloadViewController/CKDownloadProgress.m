//
//  CKDownloadProgress.m
//  aisiweb
//
//  Created by Mac on 14-6-17.
//  Copyright (c) 2014年 weiaipu. All rights reserved.
//

#import "CKDownloadProgress.h"

@interface CKDownloadProgress ()
@property(nonatomic,strong) UILabel * lblProgressInfo;
@end

@implementation CKDownloadProgress
@dynamic progress;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UIColor * defualtColor=[UIColor blueColor];
        
        //add gray line
        UIView * line=[[UIView alloc] initWithFrame:CGRectMake(0,(self.frame.size.height-1)/2,self.frame.size.width, 1)];
        line.backgroundColor=[UIColor lightGrayColor];
        line.alpha=0.5;
        line.autoresizingMask=UIViewAutoresizingFlexibleTopMargin;
        [self addSubview:line];
        
        self.lblProgressInfo=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 27, frame.size.height)];
        self.lblProgressInfo.font=[UIFont systemFontOfSize:self.frame.size.height];
        self.lblProgressInfo.backgroundColor=[UIColor clearColor];
        self.lblProgressInfo.text=@"0%";
        self.lblProgressInfo.textColor=defualtColor;
        [self addSubview:self.lblProgressInfo];
        
        
        self.progressColor=defualtColor;
        _progress=0;
        
        self.backgroundColor=[UIColor clearColor];
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    float lineHeight=1;
    float lineWidth=rect.size.width*self.progress;
    float originY=(rect.size.height-lineHeight)/2.f;
    
    CGContextRef context=UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, lineHeight);
    CGContextSetStrokeColorWithColor(context, self.progressColor.CGColor);
    CGContextMoveToPoint(context, 0,originY);
    CGContextAddLineToPoint(context, lineWidth, originY);
    CGContextStrokePath(context);
    
    
    [self setOriginX:lineWidth+1 WithView:self.lblProgressInfo];
    
    self.lblProgressInfo.textColor=self.progressColor;
    self.lblProgressInfo.text=[NSString stringWithFormat:@"%.0f%%",self.progress*100];
}


-(void) setOriginX:(float) originX  WithView:(UIView *) theView
{

    CGRect oldFrame=theView.frame;
    
    if(originX+theView.frame.size.width >= self.frame.size.width)
    {
        oldFrame.origin.x=self.frame.size.width-theView.frame.size.width;
    }
    else
    {
        oldFrame.origin.x=originX;

    }
    
    theView.frame=oldFrame;
}



#pragma mark - dynamic method
-(void) setProgress:(float)progress
{
    _progress=progress;
    [self setNeedsDisplay];
}

-(float) progress
{
    return _progress;
}

@end
