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
//task download progress
@property(nonatomic,weak) IBOutlet id<CKDownloadProgressViewProtocol>  downloadProgress;
//task status , downloading , pasue , wait and so on
@property(nonatomic,weak) IBOutlet UILabel * lblDownloadStatus;
//download rest time
@property(nonatomic,weak) IBOutlet UILabel * lblRestTime;

@end
