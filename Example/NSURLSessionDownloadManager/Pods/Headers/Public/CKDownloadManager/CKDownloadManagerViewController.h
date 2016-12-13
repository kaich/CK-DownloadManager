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

@interface CKDownloadManagerViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,weak) UITableView * tbDownloading;
@property(nonatomic,weak) UITableView * tbDownloadComplete;


/**
 config download manager,config extra block
 */
-(void) configDownloadManager;

-(void) downloadChanged;

- (NSString *) configShowTime:(NSTimeInterval) seconds;

- (void) customConfigDownloadingCell:(id<CKBaseDownloadingTableViewCellProtocol>) downloadingCell model:(id<CKDownloadModelProtocol>) model;

- (void) customConfigDownloadCompleteCell:(id<CKBaseDownloadCompleteTableViewCellProtocol>) downloadCompleteCell model:(id<CKDownloadModelProtocol>) model;
@end
