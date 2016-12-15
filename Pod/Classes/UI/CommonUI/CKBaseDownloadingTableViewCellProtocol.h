//
//  CKDownloadingTableViewCell.h
//  chengkai
//
//  Created by Mac on 14-6-17.
//  Copyright (c) 2014年 chengkai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKDownloadTableViewCellProtocol.h"
#import "CKDownloadProgressViewProtocol.h"


@protocol CKBaseDownloadingTableViewCellProtocol<CKDownloadTableViewCellProtocol>
//下载进度
@property(nonatomic,weak) IBOutlet id<CKDownloadProgressViewProtocol>  downloadProgress;
//下载状态
@property(nonatomic,weak) IBOutlet UILabel * lblDownloadStatus;
//下载剩余时间
@property(nonatomic,weak) IBOutlet UILabel * lblRestTime;
//下载速度
@property(nonatomic,weak) IBOutlet UILabel * lblSpeed;

@end
