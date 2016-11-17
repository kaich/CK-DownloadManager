//
//  CKDownHandler.h
//  DownloadManager
//  hander and task is one-to-one  mapping.
//  Created by Mac on 14-5-21.
//  Copyright (c) 2014年 Mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKDownloadModelProtocol.h"
//只有当attach 为 uitableview 的时候才会有cell
typedef void(^DownloadProgressBlock)(id<CKDownloadModelProtocol> downloadTask,CGFloat progress,CGFloat downloadContent, CGFloat totalContent,CGFloat speed,CGFloat restTime, UITableViewCell * theCell);

@interface CKDownHandler : NSObject
@property(nonatomic,weak) id target;
@property(nonatomic,copy)  DownloadProgressBlock progressBlock;
@end
