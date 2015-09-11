//
//  CKLastTouchButton.m
//  chengkai
//
//  Created by Mac on 14-6-30.
//  Copyright (c) 2014年 chengkai. All rights reserved.
//

#import "CKLastTouchButton.h"

@interface CKLastTouchButton ()
@property(nonatomic,assign) NSTimeInterval currentTime;
@property(nonatomic,assign) NSTimeInterval timeInterval;

@property(nonatomic,copy) TouchupInsideActionBlock  everyTimeActionBlock;
@property(nonatomic,copy) TouchupInsideActionBlock  finalActionBlock;
@end

@implementation CKLastTouchButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.currentTime=0;
        self.timeInterval=0.3;
        
        [self addTarget:self action:@selector(clickButton) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}



-(void) clickButton
{
    self.currentTime=[NSDate timeIntervalSinceReferenceDate];
    
    if(self.everyTimeActionBlock)
        self.everyTimeActionBlock(self);
    
    [self performSelector:@selector(performAction) withObject:nil afterDelay:self.timeInterval];
}
     
     
-(void) performAction
{
    NSTimeInterval previousTime=self.currentTime;
    NSTimeInterval nowTime =[NSDate timeIntervalSinceReferenceDate];
    NSTimeInterval interval= previousTime ? nowTime -previousTime : 0;
    

    if(interval >=self.timeInterval)
    {
        if(self.finalActionBlock)
        {
            self.finalActionBlock(self);
        }
    }
}



-(void) setTouchUpInsideEveryTimeActionBlock:(TouchupInsideActionBlock) everyTimeAtionBlock  finalAcitonBlock:(TouchupInsideActionBlock) finalBlock
{
    self.everyTimeActionBlock=everyTimeAtionBlock;
    self.finalActionBlock=finalBlock;
}

@end
