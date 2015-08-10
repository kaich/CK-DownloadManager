//
//  CKDownloadProgress.m
//  aisiweb
//
//  Created by Mac on 14-6-17.
//  Copyright (c) 2014年 weiaipu. All rights reserved.
//

#import "CKDownloadProgress.h"

@interface CKDownloadProgress ()
{
    NSTimeInterval  _currentTime;
}
@property(nonatomic,strong) UILabel * lblProgressInfo;
@property(nonatomic,strong) UIView * progressLine;

@property(nonatomic) CGFloat progress;
@end

@implementation CKDownloadProgress
@synthesize progress;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UIColor * defualtColor=[UIColor blueColor];
        self.progressColor=defualtColor;
        self.progress=0;
        _currentTime=0;
        self.backgroundColor=[UIColor clearColor];
        
        //add gray line
        UIView * line=[[UIView alloc] initWithFrame:CGRectMake(0,(self.frame.size.height-1)/2,self.frame.size.width, 0.5)];
        line.backgroundColor=[UIColor lightGrayColor];
        line.alpha=0.5;
        line.autoresizingMask=UIViewAutoresizingFlexibleTopMargin;
        [self addSubview:line];
        
        self.progressLine=[[UIView alloc] initWithFrame:CGRectMake(0,(self.frame.size.height-1)/2,self.frame.size.width, 0.5)];
        self.progressLine.backgroundColor=self.progressColor;
        self.progressLine.alpha=0.5;
        self.progressLine.autoresizingMask=UIViewAutoresizingFlexibleTopMargin;
        [self addSubview:self.progressLine];
        
        self.lblProgressInfo=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 27, frame.size.height)];
        self.lblProgressInfo.font=[UIFont systemFontOfSize:self.frame.size.height-2];
        self.lblProgressInfo.backgroundColor=[UIColor whiteColor];
        self.lblProgressInfo.text=@"0%";
        self.lblProgressInfo.textColor=[UIColor colorWithRed:112.f/255.f green:148.f/255.f blue:1.0 alpha:0.7];
        [self addSubview:self.lblProgressInfo];
        
        [self.lblProgressInfo sizeToFit];
        self.lblProgressInfo.center=CGPointMake(self.lblProgressInfo.center.x, self.frame.size.height/2);
        

    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code

}


-(void) setOriginX:(CGFloat) originX  WithView:(UIView *) theView
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


-(void) setWidth:(CGFloat) width withView:(UIView *) theView
{
    CGRect oldFrame=theView.frame;
    oldFrame.size.width=width;
    theView.frame=oldFrame;
}


#pragma mark - dynamic method
-(void) setProgress:(CGFloat) theProgress animated:(BOOL)animated;
{
     self.progress=theProgress;
    
    CGFloat oldTime=_currentTime;
    _currentTime=[NSDate timeIntervalSinceReferenceDate];
    CGFloat timeInterval =animated ? _currentTime -oldTime : 0;
    
    CGFloat lineWidth=self.frame.size.width*self.progress;
    
    [UIView animateWithDuration:timeInterval animations:^{
        self.lblProgressInfo.text=[NSString stringWithFormat:@"%.0f%%",self.progress*100];
        [self.lblProgressInfo sizeToFit];
        [self setOriginX:lineWidth+1 WithView:self.lblProgressInfo];
        
        [self setWidth:lineWidth withView:self.progressLine];
    }];
    
}

@end
