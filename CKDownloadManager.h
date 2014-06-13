//
//  CKDownloadManager.h
//  DownloadManager
//  you can use downloadManager class and inheritance downloadbaseModel ,you can't use other class.
//  Created by Mac on 14-5-21.
//  Copyright (c) 2014年 Mac. All rights reserved.
//添加了过滤功能，但是复杂程度增加了一倍不止

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
#import "CKDownHandler.h"
#import "CKDownloadBaseModel.h"


#define URL(_STR_) [NSURL URLWithString:_STR_]


typedef void(^DowloadInformationBlock)(NSString * finalPath, float downloadContentSize);
typedef void(^DownloadFinishedBlock)(id<CKDownloadModelProtocal> completedTask,NSInteger downloadIndex,NSInteger completeIndex,BOOL isFiltered);
typedef void(^DownloadDeleteBlock)(id<CKDownloadModelProtocal>  completedTask, NSInteger index, BOOL isCompleteTask);
typedef void(^DownloadStartBlock)(id<CKDownloadModelProtocal> downloadTask,NSInteger index);
typedef void(^DownloadStatusChangedBlock)(id<CKDownloadModelProtocal> downloadTask, id attachTarget);

@interface CKDownloadManager : NSObject
{
    NSMutableDictionary * _targetBlockDic;
    ASINetworkQueue * _queue;
    NSMutableDictionary * _operationsDic;
    NSMutableArray * _downloadEntityAry;
    NSMutableDictionary * _downloadEntityDic;
    NSMutableArray * _downloadCompleteEntityAry;
    NSMutableDictionary * _downloadCompleteEnttiyDic;

    id _filterParams;
}


@property(nonatomic,copy) DownloadFinishedBlock downloadCompleteBlock;
@property(nonatomic,copy) DownloadDeleteBlock downloadDeletedBlock;
@property(nonatomic,copy) DownloadStartBlock downloadStartBlock;
@property(nonatomic,copy) DownloadStatusChangedBlock downloadStatusChangedBlock;

//below property for get download information
@property(nonatomic,strong,readonly) NSArray * downloadEntities;
@property(nonatomic,strong,readonly) NSArray * downloadCompleteEntities;

//filter works on [downloadEntities] [downloadCompleteEntities],
//the model property name as the key  and  value as the value .
//this method not suggest to use, you can dealwith other download file by other part you own.
@property(nonatomic,strong) id filterParams;

/**
 *  设置model
 *
 *  @param modelClass
 */
+(void) setModel:(Class )modelClass;

/**
 *  设置后台下载
 *
 *  @param isContinue 
 */
+(void) setShouldContinueDownloadBackground:(BOOL) isContinue;

/**
 *  单例
 *
 *  @return 实例
 */
+ (instancetype)sharedInstance;

/**
 *  开始下载
 *
 *  @param url
 */
-(void) startDownloadWithURL:(NSURL *) URL  entity:(id<CKDownloadModelProtocal>) entity;

/**
 *  添加代理块  可以添加多个
 *
 *  @param block 块
 *
 *  @param url
 */
-(void) attachTarget:(id) target ProgressBlock:(DownloadProgressBlock) block  URL:(NSURL *) url;

/**
 *  默认是4为最大并发数
 *
 *  @param count 
 */
-(void) setMaxCurrentCount:(NSInteger) count;

/**
 *  暂停
 *
 *  @param url
 */
-(void) pauseWithURL:(NSURL * ) url;


/**
 *  继续下载
 *
 *  @param url 
 */
-(void) resumWithURL:(NSURL * ) url;

/**
 *  删除下载任务
 *
 *  @param url
 */
-(void) deleteWithURL:(NSURL *) url;


@end
