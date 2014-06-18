//
//  CKDownloadManager+UITableView.h
//  aisiweb
//
//  Created by Mac on 14-6-11.
//  Copyright (c) 2014年 weiaipu. All rights reserved.
//

#import "CKDownloadManager.h"

typedef void(^EtralBlock)();

@interface CKDownloadManager (UITableView)

@property(nonatomic) DownloadFinishedBlock  downloadCompleteExtralBlock;
@property(nonatomic) DownloadDeleteBlock  downloadDeleteExtralBlock;

/**
 *  设置下载 table 和 下载完成 table
 *
 *  @param downloadingTableView 下载
 *  @param completeTableView    下载完成
 */
-(void) setDownloadingTable:(UITableView *) downloadingTableView  completeTable:(UITableView * ) completeTableView;

/**
 *  下载额外完成的任务
 *
 *  @param block
 */
@end
