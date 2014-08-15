//
//  CKDownHandler.h
//  DownloadManager
//  hander and task is one-to-one  mapping.
//  Created by Mac on 14-5-21.
//  Copyright (c) 2014年 Mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKDownloadModelProtocal.h"
//只有当attach 为 uitableview 的时候才会有cell
typedef void(^DownloadProgressBlock)(id<CKDownloadModelProtocal> downloadTask,float progress,float downloadContent, float totalContent,float speed,float restTime, UITableViewCell * theCell);

@interface CKDownHandler : NSObject
@property(nonatomic,weak) id target;
@property(nonatomic,copy)  DownloadProgressBlock progressBlock;
@end
