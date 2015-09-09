//
//  CKDownloadManager+MoveDownAndRetry.h
//  chengkai
//
//  Created by mac on 15/1/5.
//  Copyright (c) 2015年 chengkai. All rights reserved.
//

#import "CKDownloadManager.h"

@interface CKDownloadManager (MoveDownAndRetry)

/**
 *  move download and retry
 *
 *  @param url
 */
-(void) moveDownAndRetryByURL:(NSURL *) url;

@end