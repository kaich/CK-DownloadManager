//
//  CKDownloadManagerViewController.h
//  chengkai
//
//  Created by Mac on 14-6-17.
//  Copyright (c) 2014年 chengkai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKDownloadManager+UITableView.h"
#import "CKBaseDownloadingTableViewCellProtocol.h"
#import "CKBaseDownloadCompleteTableViewCellProtocol.h"

@class CKBaseDownloadingTableViewCell , CKBaseDownloadCompleteTableViewCell;

static const NSString * DownloadingCellIdentifier=@"CKDownloadingTableViewCell";
static const NSString * DownloadCompleteCellIdentifier=@"CKDownloadCompleteTableViewCell";

@interface CKDownloadManagerViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,weak) UITableView * tbDownloading;
@property(nonatomic,weak) UITableView * tbDownloadComplete;



#pragma mark - Override Method

/**
  配置CKDownloadManager
 */
-(void) configDownloadManager;

/**
  下载变化时调用
 */
-(void) downloadChanged;

/**
  配置下载显示的时间格式
 @param seconds 时间
 @return 时间文本格式
 */
- (NSString *) configShowTime:(NSTimeInterval) seconds;

/**
 该方法没有任何作用，必须重载配置cell

 @param downloadingCell 下载中的Cell
 @param model 模型
 */
- (void) customConfigDownloadingCell:(id<CKBaseDownloadingTableViewCellProtocol>) downloadingCell model:(id<CKDownloadModelProtocol>) model;

/**
 该方法没有任何作用，必须重载配置cell

 @param downloadCompleteCell 下载完成Cell
 @param model 模型
 */
- (void) customConfigDownloadCompleteCell:(id<CKBaseDownloadCompleteTableViewCellProtocol>) downloadCompleteCell model:(id<CKDownloadModelProtocol>) model;
@end
