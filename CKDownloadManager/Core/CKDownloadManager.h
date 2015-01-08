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
#import "CKDownloadFileValidator.h"
#import "CKDownloadRetryController.h"
#import "CKHTTPRequestProtocal.h"


#define URL(_STR_) [NSURL URLWithString:_STR_]


typedef void(^DowloadInformationBlock)(NSString * finalPath, float downloadContentSize);
typedef void(^DownloadFinishedBlock)(id<CKDownloadModelProtocal> completedTask,NSInteger downloadIndex,NSInteger completeIndex,BOOL isFiltered);
typedef void(^DownloadDeleteBlock)(id<CKDownloadModelProtocal>  completedTask, NSInteger index, BOOL isCompleteTask,BOOL isFiltered);
typedef void(^DownloadStartBlock)(id<CKDownloadModelProtocal> downloadTask,NSInteger index);
typedef void(^DownloadStatusChangedBlock)(id<CKDownloadModelProtocal> downloadTask, id attachTarget , BOOL isFiltered);
typedef void(^DownloadDeleteAllBlock)(BOOL isDownloading , NSArray *  prapareDeleteModels , NSArray * indexPathes,BOOL isDeleteAll); //no multi section, so indexPaths defualt is section equal to zero,  isDeleteAll   yes  delete all   no  delete part.
typedef void(^DownloadStartMutilBlock)(NSArray *  prapareStartModels , NSArray * indexPathes);
typedef void(^DownloadBaseBlock)();
typedef BOOL(^DownloadPrepareBlock)();

typedef void(^DownloadAlertBlock)(id alertView);

@interface CKDownloadManager : NSObject
{
    NSMutableDictionary * _targetBlockDic;
    ASINetworkQueue * _queue;
    NSMutableDictionary * _operationsDic;
    NSMutableArray * _downloadEntityAry;
    NSMutableDictionary * _downloadEntityDic;
    NSMutableArray * _downloadCompleteEntityAry;
    NSMutableDictionary * _downloadCompleteEnttiyDic;
    
    NSMutableArray * _filterDownloadingEntities;
    NSMutableArray * _filterDownloadCompleteEntities;

    id _filterParams;
    BOOL _isAllDownloading;
}

//remember : the single delete and start call downloadDeletedBlock and downloadStartBlock. mutil task will enumerate object  will call downloadDeleteMultiEnumExtralBlock  and downloadStartMutilEnumExtralBlock. If callback not contain isFiltered field, it said run callback when task running rather than dependency task excuting. for example  DownloadDeleteAllBlock  DownloadStartMutilBlock

//download complete callback
@property(nonatomic,copy) DownloadFinishedBlock downloadCompleteBlock;
//single delete callback
@property(nonatomic,copy) DownloadDeleteBlock downloadDeletedBlock;
//start download callback
@property(nonatomic,copy) DownloadStartBlock downloadStartBlock;
//wait puase  download status changed callback
@property(nonatomic,copy) DownloadStatusChangedBlock downloadStatusChangedBlock;

//delete all or multi object callBack
@property(nonatomic,copy) DownloadDeleteAllBlock  downloadDeleteMultiBlock;
//delete all or multi enumerate ready to delete object
@property(nonatomic,copy) DownloadDeleteBlock  downloadDeleteMultiEnumExtralBlock;

//start download mutil task at same time, all started block  through  startdownloadWithURLKeyEntityDictionary method
@property(nonatomic,copy) DownloadStartMutilBlock downloadStartMutilBlock;
//mutil enumerate block will start 
@property(nonatomic,copy) DownloadStartBlock  downloadStartMutilEnumExtralBlock;

//below property for get download information
//downloading entities
@property(nonatomic,strong,readonly) NSArray * downloadEntities;
//download complete entities
@property(nonatomic,strong,readonly) NSArray * downloadCompleteEntities;
//judge wether is all downloading 
@property(nonatomic,assign,readonly) BOOL isAllDownloading;
@property(nonatomic,assign,readonly) BOOL isHasDownloading;
//filter works on [downloadEntities] [downloadCompleteEntities],
//the model property name as the key  and  value as the value .
@property(nonatomic,strong) id filterParams;

#pragma mark - componets
/**
 *   if you want validate download file , you set it
 */
@property(nonatomic,strong) CKDownloadFileValidator * fileValidator;

/**
 *  if you want retry download task , you set it
 */
@property(nonatomic,strong) CKDownloadRetryController * retryController;


#pragma mark - methods

/**
 *  开始加载数据
 */
-(void) go;
/**
 *  设置model
 *
 *  @param modelClass
 */
+(void) setModel:(Class )modelClass;

/**
 *  设置HTTP Request Class
 *
 *  @param requestClass
 */
+(void) setHTTPRequestClass:(Class<CKHTTPRequestProtocal>) requestClass;

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
 *  开始任务
 *
 *  @param URL
 *  @param entity
 *  @param dependencyDictionary key 是 URL  model 是  value
 *  @use if you use this method , you must set model.dependencies.
 */
-(void) startDownloadWithURL:(NSURL *)URL entity:(id<CKDownloadModelProtocal>)entity dependencies:(NSDictionary *) dependencyDictionary;

/**
 *  多任务下载
 *
 *  @param taskDictionary         url key    entity  value
 *  @param dependenciesDictionary url key    dependency   value
 */
-(void) startdownloadWithURLKeyEntityDictionary:(NSDictionary *)  taskDictionary   URLKeyDependenciesDictionary:(NSDictionary*) dependenciesDictionary;

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
 *  暂停全部
 */
-(void) pauseAll;


/**
 *  继续下载
 *
 *  @param url 
 */
-(void) resumWithURL:(NSURL * ) url;

/**
 *  全部开始
 */
-(void) startAllWithCancelBlock:(DownloadBaseBlock) cancelBlock;

/**
 *  删除下载任务
 *
 *  @param url
 */
-(id<CKDownloadModelProtocal>) deleteWithURL:(NSURL *) url;

/**
 *  删除全部
 *
 *  @param isDownnloading YES 下载中  NO 下载完成
 */
-(void) deleteAllWithState:(BOOL) isDownnloading;

/**
 *  多个删除
 *
 *  @param URLArray
 */
-(void) deleteTasksWithURLs:(NSArray *) URLArray  isDownloading:(BOOL) isDownloading;

/**
 *  根据URL获取model
 *
 *  @param url
 *
 *  @return model
 */
-(id<CKDownloadModelProtocal>) getModelByURL:(NSURL *) url;

@end
