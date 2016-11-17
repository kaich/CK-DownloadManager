//
//  CKDownloadManagerViewController.h
//  chengkai
//
//  Created by Mac on 14-6-17.
//  Copyright (c) 2014年 chengkai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKDownloadManager+UITableView.h"
#import "AKSegmentedControl.h"

@class CKBaseDownloadingTableViewCell , CKBaseDownloadCompleteTableViewCell;

@interface CKDownloadManagerViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,assign) BOOL isEditMode;

@property(nonatomic,weak) IBOutlet UIScrollView * scrollview;
@property(nonatomic,weak) IBOutlet UITableView * tbDownloading;
@property(nonatomic,weak) IBOutlet UITableView * tbDownloadComplete;

@property(nonatomic,weak) IBOutlet UIButton * btnEdit;
@property(nonatomic,weak) IBOutlet UIButton * btnAllDelete;
@property(nonatomic,weak) IBOutlet UIButton * btnAllDownload;

@property(nonatomic,weak) IBOutlet AKSegmentedControl * segmentControl;


- (IBAction) segmentControlValueChanged:(id)sender;
- (IBAction) editDownloadTask:(id) sender;
- (IBAction) deleteAllDownloadTask:(id) sender;

//Common method
- (void) configDownloadAllButton;
- (NSString *) configShowTime:(NSTimeInterval) seconds;
- (Class) downloadingCellClass;
- (Class) downloadCompleteCellClass;
- (void) customConfigDownloadingCell:(CKBaseDownloadingTableViewCell *) downloadingCell model:(id<CKDownloadModelProtocol>) model;
- (void) customConfigDownloadCompleteCell:(CKBaseDownloadCompleteTableViewCell *) downloadCompleteCell model:(id<CKDownloadModelProtocol>) model;
@end
