//
//  CKStateCouterManager.h
//  chengkai
//
//  Created by mac on 15/1/5.
//  Copyright (c) 2015年 chengkai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CKStateCouterManager : NSObject
{
    NSInteger _pauseCount;
    
}

@property(nonatomic,assign) BOOL isAllDownloading;
/**
 *  pause count increase, invoke when pause
 */
-(void) pauseCountIncrease;

/**
 *  pause count decrease, invoke when pause state to other state
 */
-(void) pauseCountDecrease;

/**
 *  set puase count
 *
 *  @param count
 */
-(void) setPauseCount:(NSInteger) count;

/**
 *  judge wether all is paused
 *
 *  @param taskCount
 *
 *  @return YES all paused
 */
-(BOOL) isAllPausedWithDownloadTaskCount:(NSInteger) taskCount;


@end
