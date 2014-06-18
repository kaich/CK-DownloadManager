//
//  CKDownloadingTableViewCell.h
//  aisiweb
//
//  Created by Mac on 14-6-17.
//  Copyright (c) 2014年 weiaipu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKDownloadProgress.h"
#import "CKBaseTableViewCell.h"


@interface CKDownloadingTableViewCell : CKBaseTableViewCell
{
    float _progress;
}

@property(nonatomic,strong) UIButton * btnDownload;
@property(nonatomic,strong) UILabel * lblRestTime;
@property(nonatomic,strong) UILabel * lblDownloadStatus;
@property(nonatomic) float progress;


+(float) getHeight;
@end
