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


@interface CKDownloadingTableViewCell : CKBaseTableViewCell
{
    float _progress;
}

@property(nonatomic,strong) UIButton * btnDownload;
@property(nonatomic,strong) UILabel * lblRestTime;
@property(nonatomic,strong) UILabel * lblDownloadVersion;
@property(nonatomic,strong) UILabel * lblDownloadStatus;


-(void) setProgress:(float) progress animated:(BOOL)animated;

+(CGFloat) getHeight;
@end
