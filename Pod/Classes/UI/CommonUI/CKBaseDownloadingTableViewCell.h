//
//  CKDownloadingTableViewCell.h
//  chengkai
//
//  Created by Mac on 14-6-17.
//  Copyright (c) 2014年 chengkai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKDownloadProgress.h"
#import "CKBaseTableViewCell.h"
#import "CKDownloadProgressViewProtocol.h"


@interface CKBaseDownloadingTableViewCell : CKBaseTableViewCell
//task download progress
@property(nonatomic,weak) IBOutlet id<CKDownloadProgressViewProtocol>  downloadProgress;
//task status , downloading , pasue , wait and so on
@property(nonatomic,weak) IBOutlet UILabel * lblDownloadStatus;
//download rest time
@property(nonatomic,weak) IBOutlet UILabel * lblRestTime;


@end
