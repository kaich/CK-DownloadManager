//
//  CKFreeDiskManager.h
//  chengkai
//
//  Created by mac on 15/1/8.
//  Copyright (c) 2015年 chengkai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKDownloadManager.h"

@interface CKFreeDiskManager : NSObject

@property(nonatomic,weak) CKDownloadManager * downloadManager;

@property(nonatomic,assign) long long mininumFreeSpaceBytes;

-(BOOL) isEnoughFreeSpaceWithModel:(id<CKValidatorModelProtocol>) model;

@end
