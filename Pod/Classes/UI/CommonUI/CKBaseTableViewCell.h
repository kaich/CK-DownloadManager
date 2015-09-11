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
@property(nonatomic,weak) IBOutlet UIImageView * ivImage;
@property(nonatomic,weak) IBOutlet UILabel * lblTitle;
//downloadng is speed , paused is totalReadSize/TotalSize
@property(nonatomic,weak) IBOutlet UILabel * lblDownloadInfomation;
@property(nonatomic,weak) IBOutlet UIButton * btnDownload;
@property(nonatomic,weak) IBOutlet UIButton * btnDelete;

@property(nonatomic,copy) ClickBlock  clickBlock;
@property(nonatomic,copy) DeleteBlock  deleteBlock;

- (IBAction) performDownloadAction;
- (IBAction) performDeleteAction;

+(CGFloat) getHeight;
@end
