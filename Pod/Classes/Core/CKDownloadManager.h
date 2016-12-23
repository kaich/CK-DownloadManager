//
//  CKDownloadManager.h
//  DownloadManager
//  you can use downloadManager class and inheritance downloadbaseModel ,you can't use other class.
//  Created by Mac on 14-5-21.
//  Copyright (c) 2014年 Mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKDownHandler.h"
#import "CKDownloadBaseModel.h"
#import "CKDownloadFileValidator.h"
#import "CKDownloadRetryController.h"
#import "CKHTTPRequestProtocol.h"
#import "CKMutableOrdinalDictionary.h"
#import "CKDownloadFilter.h"
#import "CKHTTPRequestQueueProtocol.h"
#import "CKDownloadAlertViewProtocol.h"
#import "CKURLDownloadTaskProtocol.h"

#define  B_TO_M(_x_)  (_x_)/1024.f/1024.f
#define  M_TO_B(_x_)  (_x_)*1024.f*1024.f
#define  B_TO_KB(_x_) (_x_)/1024.f

#define URL(_STR_) [NSURL URLWithString:_STR_]




typedef void(^DowloadInformationBlock)(NSString * finalPath, CGFloat downloadContentSize);
typedef void(^DownloadFinishedBlock)(id<CKDownloadModelProtocol> completedTask,NSInteger downloadIndex,NSInteger completeIndex,BOOL isFiltered);
typedef void(^DownloadDeleteBlock)(id<CKDownloadModelProtocol>  completedTask, NSInteger index, BOOL isCompleteTask,BOOL isFiltered);
typedef void(^DownloadStartBlock)(id<CKDownloadModelProtocol> downloadTask,NSInteger index);
typedef void(^DownloadStatusChangedBlock)(id<CKDownloadModelProtocol> downloadTask, id attachTarget , BOOL isFiltered);
typedef void(^DownloadDeleteAllBlock)(BOOL isDownloading , NSArray *  prapareDeleteModels , NSArray * indexPathes,BOOL isDeleteAll); //no multi section, so indexPaths defualt is section equal to zero,  isDeleteAll   yes  delete all   no  delete part.
typedef void(^DownloadStartMutilBlock)(NSArray *  prapareStartModels , NSArray * indexPathes);
typedef void(^DownloadBaseBlock)();
typedef BOOL(^DownloadPrepareBlock)();


@interface CKDownloadManager : NSObject
{
    NSMutableDictionary * _targetBlockDic;
    id<CKHTTPRequestQueueProtocol>  _queue;
    NSMutableDictionary * _operationsDic;
    
    CKMutableOrdinalDictionary * _downloadingEntityOrdinalDic;
    CKMutableOrdinalDictionary * _downloadCompleteEntityOrdinalDic;
    
    NSMutableArray * _filterDownloadingEntities;
    NSMutableArray * _filterDownloadCompleteEntities;
    
    NSMutableDictionary * _currentTimeDic;
    NSMutableDictionary * _currentDownloadSizeDic;

    BOOL _isAllDownloading;
    
    BOOL _shouldContinueDownloadBackground;
    
    Class _modelClass;
    Class<CKHTTPRequestProtocol> _HTTPRequestClass;
    Class<CKHTTPRequestQueueProtocol> _HTTPRequestQueueClass;
    Class<CKDownloadAlertViewProtocol> _alertViewClass;
    Class<CKURLDownloadTaskProtocol> _downloadTaskClass;
}

//remember : the single delete and start call downloadDeletedBlock and downloadStartBlock. mutil task will enumerate object  will call downloadDeleteMultiEnumExtralBlock  and downloadStartMutilEnumExtralBlock. If callback not contain isFiltered field, it said run callback when task running rather than dependency task excuting. for example  DownloadDeleteAllBlock  DownloadStartMutilBlock

#pragma mark - callback block
/**
 *  下载管理启动完成
 */
@property(nonatomic,copy) DownloadBaseBlock  downloadManagerSetupCompleteBlock;
/**
 *  下载完成回调 download complete callback
 */
@property(nonatomic,copy) DownloadFinishedBlock downloadCompleteBlock;
/**
 *  单个删除回调  single delete callback
 */
@property(nonatomic,copy) DownloadDeleteBlock downloadDeletedBlock;
/**
 *  下载开始回调  start download callback
 */
@property(nonatomic,copy) DownloadStartBlock downloadStartBlock;
/**
 *  下载状态变化回调  wait puase  download status changed callback
 */
@property(nonatomic,copy) DownloadStatusChangedBlock downloadStatusChangedBlock;
/**
 *  多个删除回调 delete all or multi object callBack  ,call after all downloadDeleteMultiEnumExtralBlock excuted.
 */
@property(nonatomic,copy) DownloadDeleteAllBlock  downloadDeleteMultiBlock;
/**
 *  删除多个单行回调 delete all or multi enumerate ready to delete object
 */
@property(nonatomic,copy) DownloadDeleteBlock  downloadDeleteMultiEnumExtralBlock;
/**
 *  多个下载回调 start download mutil task at same time, all started block  through  startdownloadWithURLKeyEntityDictionary method , call after all downloadStartMutilEnumExtralBlock excuted.
 */
@property(nonatomic,copy) DownloadStartMutilBlock downloadStartMutilBlock;
/**
 *  多个下载单行回调  mutil enumerate block will start
 */
@property(nonatomic,copy) DownloadStartBlock  downloadStartMutilEnumExtralBlock;

#pragma mark - download information property
/**
 *  下载中的任务 downloading entities
 */
@property(nonatomic,strong,readonly) NSArray * downloadEntities;
/**
 *  下载完成的任务 download complete entities
 */
@property(nonatomic,strong,readonly) NSArray * downloadCompleteEntities;
/**
 *  是否有任务正在下载中 judge wether has downloading
 */
@property(nonatomic,assign,readonly) BOOL isHasDownloading;


#pragma mark - componets
/**
 *   if you want validate download file , you set it
 */
@property(nonatomic,strong) CKDownloadFileValidator * fileValidator;

/**
 *  if you want retry download task , you set it
 */
@property(nonatomic,strong) CKDownloadRetryController * retryController;

/**
 *  过滤器（NSPredicate) filter works on [downloadEntities] [downloadCompleteEntities], the model property name as the key  and  value as the value.
 */
@property(nonatomic,strong) CKDownloadFilter * downloadFilter;


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
-(void) setModel:(Class<CKDownloadModelProtocol> )modelClass;


/**
 *  设置download task class
 *
 *  @param requestQueueClass
 */
-(void) setDownloadTaskClass:(Class<CKURLDownloadTaskProtocol>) downloadTaskClass;

/**
 *  设置Alert view class
 *
 *  @param alertViewClass
 */
-(void) setAlertViewClass:(Class<CKDownloadAlertViewProtocol>) alertViewClass;

/**
 *  单例
 *
 *  @return 实例
 */
+ (instancetype)sharedInstance;

/**
 *  设置后台下载
 *
 *  @param isContinue
 */
-(void) setShouldContinueDownloadBackground:(BOOL) isContinue;

/**
 *  开始下载
 *
 *  @param url
 */
-(void) startDownloadWithURL:(NSURL *) URL  entity:(id<CKDownloadModelProtocol>) entity;

/**
 *  开始任务
 *
 *  @param URL
 *  @param entity
 *  @param dependencyDictionary key  URL  model   value
 *  @use if you use this method , you must set model.dependencies.
 */
-(void) startDownloadWithURL:(NSURL *)URL entity:(id<CKDownloadModelProtocol>)entity dependencies:(NSDictionary *) dependencyDictionary;

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
 *  默认是3为最大并发数
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
-(void) resumeWithURL:(NSURL * ) url;

/**
 *  全部开始
 */
-(void) startAllWithCancelBlock:(DownloadBaseBlock) cancelBlock;

/**
 *  删除下载任务
 *
 *  @param url
 */
-(id<CKDownloadModelProtocol>) deleteWithURL:(NSURL *) url;

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
-(id<CKDownloadModelProtocol>) getModelByURL:(NSURL *) url;

@end
