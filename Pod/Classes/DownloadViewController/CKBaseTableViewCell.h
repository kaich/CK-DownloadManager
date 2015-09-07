//
//  CKBaseTableViewCell.h
//  chengkai
//
//  Created by Mac on 14-6-17.
//  Copyright (c) 2014年 chengkai. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CKBaseTableViewCell;

typedef void(^ClickBlock)();
typedef void(^DeleteBlock)(CKBaseTableViewCell * theCell);

@interface CKBaseTableViewCell : UITableViewCell
@property(nonatomic,strong) UIImageView * ivImage;
@property(nonatomic,strong) UILabel * lblTitle;
@property(nonatomic,strong) UILabel * lblDownloadInfo;
@property(nonatomic,strong) UIButton * btnDownload;
@property(nonatomic,strong) UIButton * btnDelete;

@property(nonatomic,copy) ClickBlock  clickBlock;
@property(nonatomic,copy) DeleteBlock  deleteBlock;
@end
