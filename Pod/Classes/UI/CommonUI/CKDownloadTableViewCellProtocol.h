//
//  CKBaseTableViewCell.h
//  chengkai
//
//  Created by Mac on 14-6-17.
//  Copyright (c) 2014年 chengkai. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CKDownloadTableViewCellProtocol;

typedef void(^ClickBlock)();
typedef void(^DeleteBlock)(id<CKDownloadTableViewCellProtocol> theCell);

@protocol CKDownloadTableViewCellProtocol<NSObject>
//下载项图片
@property(nonatomic,weak) IBOutlet UIImageView * ivImage;
//下载项名称
@property(nonatomic,weak) IBOutlet UILabel * lblTitle;
//下载信息 下载大小/总大小
@property(nonatomic,weak) IBOutlet UILabel * lblDownloadInfomation;
//下载按钮
@property(nonatomic,weak) IBOutlet UIButton * btnDownload;
//删除按钮
@property(nonatomic,weak) IBOutlet UIButton * btnDelete;

//下载按钮点击事件
- (IBAction) performDownloadAction;
//删除按钮点击事件
- (IBAction) performDeleteAction;

//下载按钮点击回调
@property(nonatomic,copy) ClickBlock  clickBlock;
//删除按钮点击回调
@property(nonatomic,copy) DeleteBlock  deleteBlock;

+(CGFloat) getHeight;
@end
