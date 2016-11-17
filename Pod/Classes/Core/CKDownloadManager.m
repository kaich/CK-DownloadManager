//
//  CKDownloadManager.m
//  DownloadManager
//
//  Created by Mac on 14-5-21.
//  Copyright (c) 2014年 Mac. All rights reserved.
//

#import "CKDownloadManager.h"
#import <objc/runtime.h>
#import "CKDownloadPathManager.h"
#import "LKDBHelper.h"
#import "Reachability.h"
#import "NSObject+LKModel.h"
#import "CKDownloadSpeedAverageQueue.h"
#import "CKStateCouterManager.h"
#import "CKHTTPRequestQueueProtocol.h"


typedef void(^AlertBlock)(id alertview);


#define  CHECK_NETWORK_HOSTNAME  @"www.baidu.com"

#define  CHECK_NO_NETWORK_MESSAGE @"请检查您的网络连接!"
#define  CHECK_WAN_NETWORK_MESSAGE @"您正在使用2G/3G网络，是否继续下载？"

#define  COMPONENT(_c_)  _c_?:nil

#define OPERATION_QUEUE(_q_) ([_q_ conformsToProtocol:@protocol(CKHTTPRequestQueueProtocol)] ?  ((id<CKHTTPRequestQueueProtocol>)_q_) : nil)

@interface CKDownloadManager()<CKHTTPRequestDelegate,CKHTTPRequestDelegate>
{

}
@property(nonatomic,strong) CKStateCouterManager * pauseCountManager;
@end

@implementation CKDownloadManager
@dynamic downloadEntities;



#pragma mark - class method


+ (instancetype)sharedInstance {
    static CKDownloadManager *_sharedInstance= nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[CKDownloadManager alloc] init];
    });
   
    return _sharedInstance;
}


-(id) init
{
    
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _modelClass=[CKDownloadBaseModel  class];
    _HTTPRequestClass = nil;
    _alertViewClass = nil;
    
    
    _operationsDic=[NSMutableDictionary dictionary];
    _targetBlockDic=[NSMutableDictionary dictionary];
    _downloadingEntityOrdinalDic = [[CKMutableOrdinalDictionary alloc] init];
    _downloadCompleteEntityOrdinalDic = [[CKMutableOrdinalDictionary alloc] init];
    _currentDownloadSizeDic=[NSMutableDictionary dictionary];
    _currentTimeDic=[NSMutableDictionary dictionary];
    
    _isAllDownloading=YES;
    _shouldContinueDownloadBackground=YES;
    _pauseCountManager=[[CKStateCouterManager alloc] init];
    
    
    //whether or not the Request is continue, the Request clear old and create new to download. This strategy in order to deal with request cancel in background task.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillTerminate) name:UIApplicationWillTerminateNotification object:nil];
    
    return self;

}

-(void) setModel:(Class<CKDownloadModelProtocol> )modelClass
{
    if ([self validateClass:modelClass withProtocol: @protocol(CKDownloadModelProtocol)]) {
        _modelClass=modelClass;
    }
}

-(void) setHTTPRequestClass:(Class<CKHTTPRequestProtocol>) requestClass
{
    if ([self validateClass:requestClass withProtocol: @protocol(CKHTTPRequestProtocol)]) {
        _HTTPRequestClass=requestClass;
    }
}

-(void) setAlertViewClass:(Class<CKDownloadAlertViewProtocol>) alertViewClass
{
    if ([self validateClass: alertViewClass withProtocol: @protocol(CKDownloadAlertViewProtocol)]) {
        _alertViewClass=alertViewClass;
    }
}

-(void) setHTTPRequestQueueClass:(Class<CKHTTPRequestQueueProtocol>) requestQueueClass
{
    if (class_conformsToProtocol(requestQueueClass, @protocol(CKHTTPRequestQueueProtocol))) {
        _HTTPRequestQueueClass=requestQueueClass;
        _queue = [_HTTPRequestQueueClass ck_createQueue];
        [_queue ck_go];
    }
}

-(void) setShouldContinueDownloadBackground:(BOOL)isContinue
{
    _shouldContinueDownloadBackground=isContinue;
}


-(void) go
{
    
    [self observeNetWorkState];
    
    NSAssert(_HTTPRequestClass, @"modelClass couldn't be nil!");
    NSAssert(_alertViewClass, @"alertViewClass couldn't be nil!");
    
    NSString * conditionNotFinish=[self downloadingCondition];
    NSString * conditionFinish=[self downloadFinishCondition];
    NSMutableArray * readyDownloadItems= [[LKDBHelper getUsingLKDBHelper] search:_modelClass where:conditionNotFinish orderBy:nil offset:0 count:0];
    NSMutableArray * finishDownloadItems =[[[LKDBHelper getUsingLKDBHelper] search:_modelClass where:conditionFinish orderBy:nil offset:0 count:0] copy];
    

    [self setPauseCount:readyDownloadItems.count];
    
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (id<CKDownloadModelProtocol> emEntity in readyDownloadItems) {
            
            NSURL * url=[NSURL URLWithString:emEntity.URLString];
            if([_HTTPRequestClass ck_isVisibleTempPath])
            {
                long long downloadSize=[[CKDownloadPathManager sharedInstance] downloadContentSizeWithURL:url];
                emEntity.downloadContentSize=downloadSize;
            }
            
            emEntity.downloadState=kDSDownloadPause;
            [[LKDBHelper getUsingLKDBHelper] updateToDB:emEntity where:nil];
            
            [_downloadingEntityOrdinalDic setObject:emEntity forKey:url];
        }
    });
    

    dispatch_group_async(group,dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        for (id<CKDownloadModelProtocol> emEntity in finishDownloadItems) {
            NSURL * url=[NSURL URLWithString:emEntity.URLString];

            [_downloadCompleteEntityOrdinalDic setObject:emEntity forKey:url];
        }
    });
    
    dispatch_group_notify(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self initializeFilterEntities];
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            if(self.downloadManagerSetupCompleteBlock)
                self.downloadManagerSetupCompleteBlock();
        });
    });
    
}

#pragma mark - instance method


-(void) startDownloadWithURL:(NSURL *)url  entity:(id<CKDownloadModelProtocol>)entity
{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        [self startDownloadWithURL:url entity:entity isMutilTask:NO prepare:^BOOL{
            return [self isEnougthFreeDiskWithModel:entity];
        }];
    });

}

-(void) startDownloadWithURL:(NSURL *)url  entity:(id<CKDownloadModelProtocol>)entity prepareBlock:(DownloadPrepareBlock) prepareBlock
{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        [self startDownloadWithURL:url entity:entity isMutilTask:NO prepare:^BOOL{
            return [self isEnougthFreeDiskWithModel:entity];
        }];
    });
    
}


-(void) startDownloadWithURL:(NSURL *)url  entity:(id<CKDownloadModelProtocol>)entity dependencies:(NSDictionary *) dependencyDictionary
{
     dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
         
        [self startDownloadWithURL:url entity:entity dependencies:dependencyDictionary isMutilTask:NO prepare:^BOOL{
            return [self isEnougthFreeDiskWithModel:entity];
        }];
         
     });
}


-(void) startdownloadWithURLKeyEntityDictionary:(NSDictionary *)taskDictionary URLKeyDependenciesDictionary:(NSDictionary *)dependenciesDictionary
{
 
    dispatch_group_t group =dispatch_group_create();
    NSMutableArray * indexPathArray=[NSMutableArray array];

    for (NSURL * emURL in taskDictionary.allKeys) {
        
            dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                id<CKDownloadModelProtocol> emModel=[taskDictionary objectForKey:emURL];
                if(dependenciesDictionary && dependenciesDictionary.count >0)
                {
                    NSDictionary * emDependencyDictionary=[dependenciesDictionary objectForKey:emURL];
                    [self startDownloadWithURL:emURL entity:emModel dependencies:emDependencyDictionary isMutilTask:YES prepare:^BOOL{
                       return [self isEnougthFreeDiskWithModel:emModel];
                    }];
                }
                else
                {
                    [self startDownloadWithURL:emURL entity:emModel isMutilTask:YES prepare:^BOOL{
                        return [self isEnougthFreeDiskWithModel:emModel];
                    }];
                }
                
                NSInteger index=[taskDictionary.allKeys indexOfObject:emURL];
                NSIndexPath * indexPath=[NSIndexPath indexPathForRow:index inSection:0];
                [indexPathArray addObject:indexPath];
            
        });
    }
    

    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        if(self.downloadStartMutilBlock)
            self.downloadStartMutilBlock(taskDictionary.allValues,indexPathArray);
    });
    
}



-(void)attachTarget:(id)target ProgressBlock:(DownloadProgressBlock)block URL:(NSURL *)URL
{
    CKDownHandler * oldHandler=[_targetBlockDic objectForKey:URL];
    if(target && oldHandler.target==target)
        return ;
    
    
    CKDownHandler * handler=[[CKDownHandler alloc] init];
    handler.target=target;
    handler.progressBlock=block;
    
    [_targetBlockDic setObject:handler forKey:URL];
}

-(void) setMaxCurrentCount:(NSInteger)count
{
    OPERATION_QUEUE(_queue).ck_maxConcurrentOperationCount=count;
}


-(void) pauseWithURL:(NSURL *)url
{
    [self pauseWithURL:url autoResum:NO];
}


-(void) pauseAll
{
    [self pauseAllWithAutoResum:NO complete:nil];
}


-(void) resumeWithURL:(NSURL *)url
{
    if([self isWWAN])
    {
        [self showWWANWarningWithDoneBlock:^(id alertView) {
            [self resumeTaskWithURL:url];
        } cancelBlock:nil];
    }
    else if([self isWifi])
    {
        [self resumeTaskWithURL:url];
    }
    else
    {
        [self alertWhenNONetwork];
    }
}


-(void) startAllWithCancelBlock:(DownloadBaseBlock) cancelBlock
{
    @synchronized(self)
    {
        if([self isWWAN])
        {
            [self showWWANWarningWithDoneBlock:^(id alertView) {
                [self resumAllWithAutoResum:NO];
            } cancelBlock:cancelBlock];
        }
        else if([self isWifi])
        {
            [self resumAllWithAutoResum:NO];
        }
        else
        {
            [self alertWhenNONetwork];
        }
    }

}


-(id<CKDownloadModelProtocol>) deleteWithURL:(NSURL *)url
{
   return [self deleteWithURL:url deleteFile:YES deleteDependencies:YES];
}


-(void) deleteAllWithState:(BOOL) isDownnloading
{
    
    if(isDownnloading)
    {
       @synchronized(self)
        {
            NSArray * downloadingArray=[self downloadEntities];

            NSMutableArray * indexPathArray=[NSMutableArray array];
            for (id<CKDownloadModelProtocol> emModel in downloadingArray) {
                NSInteger index=[downloadingArray indexOfObject:emModel];
                NSIndexPath * indexPath=[NSIndexPath indexPathForRow:index inSection:0];
                [indexPathArray addObject:indexPath];
                
                [self deleteAllEmumTraskAndDependencyWithURL:URL(emModel.URLString)];
            }
            
      
            if(self.downloadDeleteMultiBlock)
                self.downloadDeleteMultiBlock(isDownnloading,(NSArray*)downloadingArray,indexPathArray,YES);

        }

    }
    else
    {
        @synchronized(self)
        {
            NSArray * downloadCompleteArray=[self downloadCompleteEntities];

            NSMutableArray * indexPathArray=[NSMutableArray array];
            for (id<CKDownloadModelProtocol> emModel in downloadCompleteArray) {
                NSInteger index=[downloadCompleteArray indexOfObject:emModel];
                NSIndexPath * indexPath=[NSIndexPath indexPathForRow:index inSection:0];
                [indexPathArray addObject:indexPath];
                
                [self deleteAllEmumTraskAndDependencyWithURL:URL(emModel.URLString)];
            }
        
            if(self.downloadDeleteMultiBlock)
                self.downloadDeleteMultiBlock(isDownnloading,(NSArray*)downloadCompleteArray,indexPathArray,YES);

        }
    }
    
}


-(void) deleteTasksWithURLs:(NSArray *) URLArray isDownloading:(BOOL)isDownloading
{
    @synchronized(self)
    {
        
        NSMutableDictionary * allEntityDic=[NSMutableDictionary dictionaryWithDictionary:_downloadingEntityOrdinalDic.dictionary];
        [allEntityDic addEntriesFromDictionary:_downloadCompleteEntityOrdinalDic.dictionary];
        
        NSArray * downloadingArray= [self downloadEntities];
        NSArray * completeArray= [self downloadCompleteEntities];
        
        NSMutableArray * deleteModels=[NSMutableArray array];
        NSMutableArray * indexPathArray=[NSMutableArray array];
        for (NSURL * emURL in URLArray) {
            id<CKDownloadModelProtocol> emModel=[allEntityDic objectForKey:emURL];
            [deleteModels  addObject:emModel];
            
            
            NSInteger index=0;
            if([downloadingArray containsObject:emModel])
            {
                index=[downloadingArray indexOfObject:emModel];
            }
            else
            {
                index=[completeArray indexOfObject:emModel];
            }
            
            NSIndexPath * indexPath=[NSIndexPath indexPathForRow:index inSection:0];
            [indexPathArray addObject:indexPath];
            
            [self deleteAllEmumTraskAndDependencyWithURL:URL(emModel.URLString)];
        }
        
        
        if(self.downloadDeleteMultiBlock)
            self.downloadDeleteMultiBlock(isDownloading,(NSArray*)deleteModels,indexPathArray,NO);
        
    }

}


-(id<CKDownloadModelProtocol>) getModelByURL:(NSURL *)url
{
    id<CKDownloadModelProtocol> model=nil;
    
    if((model=[_downloadingEntityOrdinalDic objectForKey:url]))
    {
        return model;
    }
    else
    {
        model=[_downloadCompleteEntityOrdinalDic objectForKey:url];
        return model;
    }
}


#pragma mark - private method


#pragma mark - filter  and database
//sql fetch condition
-(NSString *) downloadingCondition
{
    NSString * conditionNotFinish=[NSString stringWithFormat:@"%@ != '%d'",DOWNLOAD_STATE,kDSDownloadComplete];
    return conditionNotFinish;
}


-(NSString *) downloadFinishCondition
{
    NSString * conditionFinish=[NSString stringWithFormat:@"%@ = '%d'",DOWNLOAD_STATE,kDSDownloadComplete];
    return conditionFinish;
}


-(void) initializeFilterEntities
{
    if(_filterDownloadingEntities==nil)
    {
        _filterDownloadingEntities=  [self.downloadFilter filteArray:_downloadingEntityOrdinalDic.array];
    }
    
    if(_filterDownloadCompleteEntities==nil)
    {
        _filterDownloadCompleteEntities= [self.downloadFilter filteArray:_downloadCompleteEntityOrdinalDic.array];
    }
}


#pragma mark - download actions

-(void) downloadExistTaskWithURL:(NSURL *) url
{
    id<CKHTTPRequestProtocol> request=[self createRequestWithURL:url];
    NSMutableArray * requestArray=[NSMutableArray arrayWithObject:request];
    
    id<CKDownloadModelProtocol> model =[_downloadingEntityOrdinalDic objectForKey:url];
    for (NSURL * emURL in model.dependencies) {
        id<CKHTTPRequestProtocol> emRequest=[_operationsDic objectForKey:emURL];
        id<CKDownloadModelProtocol> model =[_downloadingEntityOrdinalDic objectForKey:emURL];
        model.downloadState=kDSWaitDownload;
        if((emRequest.ck_status == kRSCanceled)  && !emRequest && ![_downloadCompleteEntityOrdinalDic objectForKey:emURL])
        {
            emRequest=[self createRequestWithURL:emURL];
            [request ck_addDependency:emRequest];
            [requestArray addObject:emRequest];
        }
    }
    

    [self downloadWithRequest:requestArray];
}


-(id<CKHTTPRequestProtocol>) createRequestWithURL:(NSURL *) url
{
    id<CKHTTPRequestProtocol> oldRequest=[_operationsDic objectForKey:url];
    if(oldRequest)
    {
        [oldRequest ck_clearDelegatesAndCancel];
    }
    
    id<CKHTTPRequestProtocol> newRequest =[_HTTPRequestClass ck_createDownloadRequestWithURL:url];
    [newRequest ck_setShouldContinueWhenAppEntersBackground:_shouldContinueDownloadBackground];
    newRequest.ck_delegate = self;
    
    [_operationsDic setObject:newRequest forKey:url];
    
    return newRequest;
}


-(void) downloadWithRequest:(NSArray *) requestArray
{
    for (id<CKHTTPRequestProtocol> emRequest in requestArray)
    {
        id<CKDownloadModelProtocol> model = [_downloadingEntityOrdinalDic objectForKey:emRequest.ck_url];
        [COMPONENT(self.retryController) cancelTaskAutoResum:(id<CKDownloadModelProtocol,CKRetryModelProtocol>)model];
        [COMPONENT(self.retryController) resetRetryCountWithModel:(id<CKDownloadModelProtocol,CKRetryModelProtocol>)model];
        
        if(![OPERATION_QUEUE(_queue).ck_operations containsObject:emRequest])
        {
            [OPERATION_QUEUE(_queue) ck_addRequest:emRequest];
            [self pauseCountDecrease];
        }
    
        [self excuteStatusChangedBlock:emRequest.ck_url];
    }
    
    if(OPERATION_QUEUE(_queue).ck_isSuspended)
        [_queue ck_go];
}


-(void) addNewTask:(NSURL *) url  entity:(id<CKDownloadModelProtocol>) entity   isMultiTask:(BOOL) isMutilTask
{
    @synchronized(self)
    {
        NSString * toPath=nil;
        NSString * tmpPath=nil;
        [[CKDownloadPathManager sharedInstance] SetURL:url toPath:&toPath tempPath:&tmpPath];
        
        id<CKDownloadModelProtocol>  model=nil;
        if(entity)
        {
            model=entity;
        }
        else
        {
            model=[[_modelClass alloc] init];
        }
        model.URLString=url.absoluteString;
        model.downloadFinalPath=toPath;
        model.downloadState=kDSWaitDownload;
        if(model.title.length==0)
        {
            model.title=[url lastPathComponent];
        }
        
        [self updateDataBaseWithModel:model];
        
        [self pauseCountIncrease]; //this code for let the pause count equal to 0
        
        
        if([self checkExitTask:url])
            return  ;
        
        [_downloadingEntityOrdinalDic setObject:model forKey:url];
        
        NSInteger index=0;
        
        if(self.downloadFilter)
        {
            BOOL result=[self.downloadFilter filtePassed:model];
            if (result) {
                [_filterDownloadingEntities addObject:model];
                index=_filterDownloadingEntities.count-1;
                
                if(isMutilTask)
                {
                    dispatch_sync(dispatch_get_main_queue(), ^(void) {
                        if(self.downloadStartMutilEnumExtralBlock)
                            self.downloadStartMutilEnumExtralBlock(model,index);
                    });
                }
                else
                {
                    dispatch_sync(dispatch_get_main_queue(), ^(void) {
                        if(self.downloadStartBlock)
                            self.downloadStartBlock(model,index);
                    });
                }
            }
        }
        else
        {
            index=_downloadingEntityOrdinalDic.count-1;
            
            if(isMutilTask)
            {
                dispatch_sync(dispatch_get_main_queue(), ^(void) {
                    if(self.downloadStartMutilEnumExtralBlock)
                        self.downloadStartMutilEnumExtralBlock(model,index);
                });
            }
            else
            {
                dispatch_sync(dispatch_get_main_queue(), ^(void) {
                    if(self.downloadStartBlock)
                        self.downloadStartBlock(model,index);
                });
            }
        }
        
        
    }
    
}


-(void) addNewTask:(NSURL *) url entity:(id<CKDownloadModelProtocol>)entity  dependencies:(NSDictionary * ) dependencies isMutilTask:(BOOL) isMutilTask
{
    @synchronized(self)
    {
        for(NSURL * emURL in dependencies.allKeys) {
            id<CKDownloadModelProtocol> emModel=[dependencies objectForKey:emURL];
            [self  addNewTask:emURL entity:emModel isMultiTask:isMutilTask];
        }
        
        [self addNewTask:url entity:entity isMultiTask:isMutilTask];
    }
}


-(void) resumeTaskWithURL:(NSURL *) url
{
    id<CKDownloadModelProtocol> model=[_downloadingEntityOrdinalDic objectForKey:url];
    id<CKHTTPRequestProtocol>  request=[_operationsDic objectForKey:url];
    if(model && ((model.downloadState!=kDSDownloading && model.downloadState!=kDSWaitDownload) || request.ck_status==kRSCanceled || request ==nil))
    {
        
        model.downloadState=kDSWaitDownload;

        [self updateDataBaseWithModel:model];
        
        [self downloadExistTaskWithURL:url];
    }
    
}


#define  DELETE_MODEL_KEY  @"delete model"
#define  DELETE_INDEX_KEY  @"delete index"
#define  DELETE_COMPLETE_STATE_KEY  @"delete complete state"
#define  DELETE_FILTER_KEY  @"delete filter"

/**
 *  return
 *
 *  @param url
 *
 *  @return DELETE_MODEL_KEY DELETE_INDEX_KEY DELETE_COMPLETE_STATE_KEY DELETE_FILTER_KEY
 */
-(NSDictionary *) deleteTaskWithURLWithNoCallBack:(NSURL*) url  deleteFile:(BOOL) isNeed
{
    if(url.absoluteString.length >0)
    {
        
        BOOL  isCompleteTask=YES;
        id<CKDownloadModelProtocol>  model=nil;
        NSInteger index=-1;
        BOOL isFiltered=YES;
        
        id<CKDownloadModelProtocol>  modelFinished=[_downloadCompleteEntityOrdinalDic objectForKey:url];
        id<CKDownloadModelProtocol>  modelNotFinished=[_downloadingEntityOrdinalDic objectForKey:url];
        if(modelFinished)
        {
            
            model=modelFinished;
            
            index=[_downloadCompleteEntityOrdinalDic indexOfObject:modelFinished];
            
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
                [[LKDBHelper getUsingLKDBHelper] deleteToDB:modelFinished];
            });

            [_downloadCompleteEntityOrdinalDic removeObjectForKey:url];
            
            if(self.downloadFilter)
            {
                isFiltered = NO;
                if([_filterDownloadCompleteEntities containsObject:model])
                {
                    index=[_filterDownloadCompleteEntities indexOfObject:model];
                    [_filterDownloadCompleteEntities removeObject:model];
                    isFiltered=YES;
                }
            }
            
            isCompleteTask=YES;
            
        }
        else if(modelNotFinished)
        {
            model=modelNotFinished;
            
            index=[_downloadingEntityOrdinalDic indexOfObject:modelNotFinished];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
                [[LKDBHelper getUsingLKDBHelper] deleteToDB:modelNotFinished];
            });

            [_downloadingEntityOrdinalDic removeObjectForKey:url];
            
            
            if(self.downloadFilter)
            {
                isFiltered = NO;
                if([_filterDownloadingEntities containsObject:model])
                {
                    index=[_filterDownloadingEntities indexOfObject:model];
                    [_filterDownloadingEntities removeObject:model];
                    isFiltered=YES;
                }
            }
            
            isCompleteTask=NO;
            
            if(!(model.downloadState==kDSWaitDownload || model.downloadState==kDSDownloading))
            {
                [self pauseCountDecrease];
            }
        }
        
        
        if(model)
        {
            id<CKHTTPRequestProtocol> request=[_operationsDic objectForKey:url];
            [request ck_clearDelegatesAndCancel];
            [_operationsDic removeObjectForKey:url];
            [_currentTimeDic removeObjectForKey:url];
            [_currentDownloadSizeDic removeObjectForKey:url];
            
            if(isNeed)
            {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
                    [[CKDownloadPathManager sharedInstance] removeFileWithURL:url];
                });
            }

            return  @{DELETE_MODEL_KEY: model,
                      DELETE_INDEX_KEY : [NSNumber numberWithInteger:index],
                      DELETE_FILTER_KEY : [NSNumber numberWithBool:isFiltered],
                      DELETE_COMPLETE_STATE_KEY : [NSNumber numberWithBool:isCompleteTask]};
        }
        
        return  nil;
    }
    
    return  nil;
}


-(void) deleteTaskWithURL:(NSURL*) url  deleteFile:(BOOL) isNeed
{
    if(url.absoluteString.length >0)
    {
        
        NSDictionary * deleteInfoDic= [self deleteTaskWithURLWithNoCallBack:url deleteFile:isNeed];
        if(deleteInfoDic)
        {
            NSInteger index=[[deleteInfoDic objectForKey:DELETE_INDEX_KEY] integerValue];
            BOOL isCompleteTask=[[deleteInfoDic objectForKey:DELETE_COMPLETE_STATE_KEY]boolValue];
            BOOL isFiltered=[[deleteInfoDic objectForKey:DELETE_FILTER_KEY]boolValue];
            id<CKDownloadModelProtocol> model=[deleteInfoDic objectForKey:DELETE_MODEL_KEY];
            
            if(index >=0)
            {
                
                if(self.downloadDeletedBlock)
                    self.downloadDeletedBlock(model,index,isCompleteTask,isFiltered);
            }
        }
    }
}

-(id<CKDownloadModelProtocol>) deleteWithURL:(NSURL *)url deleteFile:(BOOL) isNeed deleteDependencies:(BOOL) isNeedDeleteDependencies
{
    if(url.absoluteString.length>0)
    {
        id<CKDownloadModelProtocol>  model=[_downloadCompleteEntityOrdinalDic objectForKey:url];
        if(!model)
            model=[_downloadingEntityOrdinalDic objectForKey:url];
        if(isNeedDeleteDependencies)
        {
            for (NSURL * emURL in model.dependencies) {
                if(emURL.absoluteString.length>0)
                    [self deleteTaskWithURL:emURL deleteFile:isNeed];
            }
        }
        [self deleteTaskWithURL:url deleteFile:isNeed];
        
        return model;
    }
    
    return nil;
}


-(void) deleteAllEmumTraskAndDependencyWithURL:(NSURL*) url
{
    if(url.absoluteString.length>0)
    {
        id<CKDownloadModelProtocol>  model=[_downloadCompleteEntityOrdinalDic objectForKey:url];
        if(!model)
            model=[_downloadingEntityOrdinalDic objectForKey:url];
        
        for (NSURL * emURL in model.dependencies) {
            if(emURL.absoluteString.length>0)
                [self deleteAllEmumTaskWithURL:emURL];
        }
        
        [self deleteAllEmumTaskWithURL:url];
    }
}


-(void) deleteAllEmumTaskWithURL:(NSURL*) url
{
    if(url.absoluteString.length >0)
    {
        
        NSDictionary * deleteInfoDic= [self deleteTaskWithURLWithNoCallBack:url deleteFile:YES];
        if(deleteInfoDic)
        {
            NSInteger index=[[deleteInfoDic objectForKey:DELETE_INDEX_KEY] integerValue];
            BOOL isCompleteTask=[[deleteInfoDic objectForKey:DELETE_COMPLETE_STATE_KEY]boolValue];
            BOOL isFiltered=[[deleteInfoDic objectForKey:DELETE_FILTER_KEY]boolValue];
            id<CKDownloadModelProtocol> model=[deleteInfoDic objectForKey:DELETE_MODEL_KEY];
            
            if(index >=0)
            {
                
                if(self.downloadDeleteMultiEnumExtralBlock)
                    self.downloadDeleteMultiEnumExtralBlock(model,index,isCompleteTask,isFiltered);
            }
        }
        
    }
}


#pragma mark - network

-(BOOL) isWifi
{
    Reachability * rb =[Reachability reachabilityForLocalWiFi];
    return  rb.isReachableViaWiFi;
}

-(BOOL) isWWAN
{
    Reachability * rb =[Reachability reachabilityForInternetConnection];
    return  rb.isReachableViaWWAN;
}

//network status
-(void) observeNetWorkState
{
    Reachability * rb =[Reachability reachabilityWithHostname:CHECK_NETWORK_HOSTNAME];
    rb.reachableBlock=^(Reachability * reachability){
        if([reachability isReachableViaWWAN])
        {
            [OPERATION_QUEUE(_queue) ck_setSuspended:YES];
            [self pauseAllWithAutoResum:YES complete:^{
                
                if(self.retryController)
                {
                    if(self.retryController.resumCount >0)
                    {
                        dispatch_async(dispatch_get_main_queue(), ^(void) {
                            [_alertViewClass dismissAllAlertView];
                            [self showWWANWarningWithDoneBlock:^(id alertview) {
                                [_queue ck_go];
                                [self resumAllWithAutoResum:YES];
                            } cancelBlock:^(id alert){
                                [self pauseAll];
                            }];
                        });
                        
                    }
                }
                
            }];
            
        }
        
        if([reachability isReachableViaWiFi])
        {
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                [_alertViewClass dismissAllAlertView];
                
                [self resumAllWithAutoResum:YES];
                [_queue ck_go];
            });
        }
    };
    
    
    rb.unreachableBlock=^(Reachability * reachability){
        if(![self isAllPaused])
        {
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                [self alertWhenNONetwork];
                [self pauseAll];
            });
        }
        
    };
    
    [rb startNotifier];
}

#pragma mark - alert view

-(void) alertWhenNONetwork
{
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        
        id<CKDownloadAlertViewProtocol>  alertview=[_alertViewClass alertViewWithTitle:@"提示" message:CHECK_NO_NETWORK_MESSAGE cancelButtonTitle:@"确定" sureTitle:nil  cancelBlock:^(id alert){
            
        } sureBlock:nil];
        [alertview show];
        
    });
    
}

-(void) showWWANWarningWithDoneBlock:(AlertBlock) block cancelBlock:(DownloadAlertBlock) cancelBlock
{
    dispatch_async(dispatch_get_main_queue(), ^(void) {

        id<CKDownloadAlertViewProtocol>  alert=[_alertViewClass alertViewWithTitle:@"提示" message:CHECK_WAN_NETWORK_MESSAGE cancelButtonTitle:@"取消" sureTitle:@"确定" cancelBlock:^(id alert){
            if(cancelBlock)
                cancelBlock(alert);
        } sureBlock:^(id alert){
            if(block)
                block(alert);
        }];
        
        [alert show];
        
    });
}


#pragma mark - callback

-(void) excuteStatusChangedBlock:(NSURL*) url
{
    if(self.downloadStatusChangedBlock)
    {
        BOOL isFiltered=YES;
        id<CKDownloadModelProtocol> model=[_downloadingEntityOrdinalDic objectForKey:url];
        
        if(self.downloadFilter)
        {
            isFiltered=[_filterDownloadingEntities containsObject:model];
        }
        
        CKDownHandler* handler=[_targetBlockDic objectForKey:url];
        if([handler.target isKindOfClass:[UITableView class]])
        {
            NSInteger index=0;
            if(isFiltered)
            {
                index=[_filterDownloadingEntities indexOfObject:model];
            }
            else
            {
                index=[self.downloadEntities indexOfObject:model];
            }
            NSIndexPath * indexPath=[NSIndexPath indexPathForRow:index inSection:0];
            UITableViewCell * cell=[handler.target cellForRowAtIndexPath:indexPath];
            
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                self.downloadStatusChangedBlock(model,cell,isFiltered);
                
                if(model.downloadState==kDSDownloadPause)
                {
                    [self excuteProgressChangedBlock:model.downloadContentSize totoalSize:model.totalCotentSize speed:0 url:url];
                }
            });
            
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                self.downloadStatusChangedBlock(model,handler.target,isFiltered);
            });
        }
    }

}

-(void) excuteProgressChangedBlock:(long long) downloadSize totoalSize:(long long ) totoalSize speed:(long long) speed url:(NSURL*) url;
{
    CGFloat progress=0;
    if(downloadSize >0 && totoalSize >0)
    {
       progress=(CGFloat)downloadSize/(CGFloat)totoalSize;
    }
    
    NSTimeInterval restTime=speed ? (totoalSize-downloadSize)/speed : MAXFLOAT;
    
    id<CKDownloadModelProtocol>  model=[_downloadingEntityOrdinalDic objectForKey:url];
    model.downloadContentSize=downloadSize;
    model.speed=speed;
    model.restTime=restTime;
    CKDownHandler * handler=[_targetBlockDic objectForKey:url];
    if([handler.target isKindOfClass:[UITableView class]])
    {
        NSInteger index=[self.downloadEntities indexOfObject:model];
        NSIndexPath * indexPath=[NSIndexPath indexPathForRow:index inSection:0];
        UITableViewCell * cell=[handler.target cellForRowAtIndexPath:indexPath];
        
        if(cell)
        {
            handler.progressBlock(model,progress,downloadSize,totoalSize,speed,restTime,cell);
        }
        
    }
    else
    {
        if(handler.target)
        {
            handler.progressBlock(model,progress,downloadSize,totoalSize,speed,restTime,nil);
        }
    }


}

#pragma mark - download task method

-(void) startDownloadWithURL:(NSURL *)url  entity:(id<CKDownloadModelProtocol>)entity  isMutilTask:(BOOL) isMutilTask prepare:(DownloadPrepareBlock) prepareBlock
{
    [self startDownloadWithURL:url entity:entity dependencies:nil isMutilTask:isMutilTask prepare:prepareBlock];
}


-(void) startDownloadWithURL:(NSURL *)url  entity:(id<CKDownloadModelProtocol>)entity dependencies:(NSDictionary *) dependencyDictionary  isMutilTask:(BOOL) isMutilTask  prepare:(DownloadPrepareBlock) prepareBlock
{

    //如果已经在下载列表 返回
    if([self checkExitTask:url] )
    {
        return ;
    }
    
    
    if(prepareBlock)
    {
        BOOL isOK = prepareBlock();
        if(!isOK)
            return ;
    }
    
    if([self isWWAN])
    {

        [self showWWANWarningWithDoneBlock:^(id alertView) {

            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
                [self addNewTask:url entity:entity dependencies:dependencyDictionary isMutilTask:isMutilTask];
                [self downloadExistTaskWithURL:url];
            });
            
        } cancelBlock:nil];
    }
    else if([self isWifi])
    {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
            [self addNewTask:url entity:entity dependencies:dependencyDictionary isMutilTask:isMutilTask];
            [self downloadExistTaskWithURL:url];
        });
    }
    else
    {
        [self alertWhenNONetwork];
    }
    
}


-(void) resumAllWithAutoResum:(BOOL) isAutoResum
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        
        @synchronized(self)
        {
        
            NSArray * downloadEntityArray=nil;
            if(self.downloadFilter)
            {
                downloadEntityArray=[_filterDownloadingEntities copy];
            }
            else
            {
                downloadEntityArray=_downloadingEntityOrdinalDic.array;
            }
            for (id<CKDownloadModelProtocol> emModel in downloadEntityArray) {
                if(isAutoResum)
                {
              
                    if([COMPONENT(self.retryController) isAutoResumWithModel:(id<CKDownloadModelProtocol,CKRetryModelProtocol>)emModel])
                    {
                        [self resumeTaskWithURL:URL(emModel.URLString)];
                    }
                    
                }
                else
                {
                    [self resumeTaskWithURL:URL(emModel.URLString)];
                }
            }
            
            if(isAutoResum==NO)
            {
                if(self.pauseCountManager)
                {
                    [self.pauseCountManager setPauseCount:0];
                }
            }
        }
    });
}


-(void) pauseTaskWithURL:(NSURL*) url  autoResum:(BOOL) isAutoResum
{
    id<CKHTTPRequestProtocol>  request=[_operationsDic objectForKey:url];
    id<CKDownloadModelProtocol> model=[_downloadingEntityOrdinalDic objectForKey:url];
    if(request && (model.downloadContentSize  < model.totalCotentSize || model.totalCotentSize ==0) && (model.downloadState==kDSDownloading || model.downloadState==kDSWaitDownload))
    {
        if(self.retryController)
        {
            if(isAutoResum)
            {
                [self.retryController makeTaskAutoResum:(id<CKDownloadModelProtocol,CKRetryModelProtocol>)model];
            }
            else
            {
                [self.retryController cancelTaskAutoResum:(id<CKDownloadModelProtocol,CKRetryModelProtocol>)model];
            }
        }
        
        model.downloadState=kDSDownloadPause;
        model.restTime=MAXFLOAT;
        
        [self updateDataBaseWithModel:model];
        
        CKDownloadSpeedAverageQueue * speedQueue=[_currentDownloadSizeDic objectForKey:url];
        [speedQueue reset];
        
        
        if(!(request.ck_status == kRSCanceled || request.ck_status == kRSFinished))
        {
            [self pauseCountIncrease];
        }
        
        [request ck_clearDelegatesAndCancel];
        
        [self excuteStatusChangedBlock:url];
    }
}

-(void) pauseWithURL:(NSURL *)url autoResum:(BOOL) isAutoResum
{
    id<CKDownloadModelProtocol> model =[_downloadingEntityOrdinalDic objectForKey:url];
    for(NSURL * emDependencyURL in model.dependencies){
        if([_downloadingEntityOrdinalDic objectForKey:emDependencyURL])
            [self pauseTaskWithURL:emDependencyURL autoResum:isAutoResum];
    }
    [self pauseTaskWithURL:URL(model.URLString) autoResum:isAutoResum];
}

-(void) pauseAllWithAutoResum:(BOOL) isAutoResum  complete:(DownloadBaseBlock) completeBlock
{

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
            @synchronized(self)
            {
                NSArray * downloadingArray=nil;
                if(self.downloadFilter)
                {
                    downloadingArray=[_filterDownloadingEntities copy];
                }
                else
                {
                    downloadingArray=[_downloadingEntityOrdinalDic copy];
                }
                
                for (id<CKDownloadModelProtocol> emModel in downloadingArray) {
                    [self pauseWithURL:URL(emModel.URLString) autoResum:isAutoResum];
                }
                
                [self resetPauseCount];
                
                if(completeBlock)
                    completeBlock();
            }
        });

}


-(BOOL) checkExitTask:(NSURL*) url
{
    if([_downloadCompleteEntityOrdinalDic objectForKey:url] || [_downloadingEntityOrdinalDic  objectForKey:url])
    {
        return YES;
    }
    
    return  NO;
}

-(BOOL) isEnougthFreeDiskWithModel:(id<CKDownloadModelProtocol>) model
{
    if(self.fileValidator)
    {
        return  [self.fileValidator validateEnougthFreeSpaceWithModel:(id<CKValidatorModelProtocol,CKDownloadModelProtocol>)model];
    }
    else
    {
        return YES;
    }
}


-(void) downloadSuccesfulWithModel:(id<CKDownloadModelProtocol> ) model  request:(id<CKHTTPRequestProtocol>) request
{
    
    model.downloadState=kDSDownloadComplete;
    model.downloadTime=[NSDate date];
    [self updateDataBaseWithModel:model];
    
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        
        NSInteger index=0,completeIndex=0;
        
        if(self.downloadFilter)
        {
            if([_filterDownloadingEntities containsObject:model])
            {
                index=[_filterDownloadingEntities indexOfObject:model];
                completeIndex= _filterDownloadCompleteEntities.count;
                
                [_filterDownloadingEntities removeObject:model];
                [_filterDownloadCompleteEntities addObject:model];
            }
        }
        else
        {
            index=[self.downloadEntities indexOfObject:model];
            completeIndex=self.downloadCompleteEntities.count;
        }
        
        [_targetBlockDic removeObjectForKey:request.ck_url];
        [_operationsDic removeObjectForKey:request.ck_url];
        
        [_downloadingEntityOrdinalDic removeObjectForKey:request.ck_url];
        [_downloadCompleteEntityOrdinalDic setObject:model forKey:request.ck_url];
        
        
        if(self.downloadCompleteBlock)
        {
            if(self.downloadFilter)
            {
                BOOL isFiltered=[_filterDownloadCompleteEntities containsObject:model];
                
                self.downloadCompleteBlock(model,index,completeIndex,isFiltered);
                
            }
            else
            {
                self.downloadCompleteBlock(model,index,completeIndex,YES);
            }
        }
    });
    
}


#pragma mark - puase state

-(void) pauseCountIncrease
{
    [_pauseCountManager pauseCountIncrease];
}


-(void) pauseCountDecrease
{
    [_pauseCountManager pauseCountDecrease];
}

-(void) resetPauseCount
{
    [_pauseCountManager setPauseCount:_downloadingEntityOrdinalDic.count];
}

-(void) setPauseCount:(NSInteger) count
{
    [_pauseCountManager setPauseCount:count];
}

-(BOOL) isAllPaused
{
    NSInteger taskCount=0;
    taskCount=_downloadingEntityOrdinalDic.count;
    return  [_pauseCountManager isAllPausedWithDownloadTaskCount:taskCount];
}

-(void) setAllPauseStatus
{
    NSString * pauseCondition=[NSString stringWithFormat:@"%@ = '%d'",DOWNLOAD_STATE,kDSDownloadPause];
    [[LKDBHelper getUsingLKDBHelper] updateToDB:_modelClass set:pauseCondition where:[self downloadingCondition]];
}


#pragma mark - extend method 
-(void) updateDataBaseWithModel:(id<CKDownloadModelProtocol>) model
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        if([[LKDBHelper getUsingLKDBHelper] isExistsModel:model])
        {
            [[LKDBHelper getUsingLKDBHelper] updateToDB:model where:nil];
        }
        else
        {
            [[LKDBHelper getUsingLKDBHelper] insertToDB:model];
        }
    });
}

-(NSArray *) allDowndingTask
{
    return  _downloadingEntityOrdinalDic.array;
}

-(BOOL) validateClass:(Class) aClass withProtocol:(Protocol *) aProtocol
{
    if (class_conformsToProtocol(aClass, aProtocol)) {
        return YES;
    }
    else
    {
        NSString * className = NSStringFromClass(aClass);
        NSString * protocolName = NSStringFromProtocol(aProtocol);
        NSAssert(0, @"%@ isn't comform to Protocol %@!",className,protocolName);
        return NO;
    }
}

#pragma mark - HTTP request delegate
-(void) ck_requestStarted:(id<CKHTTPRequestProtocol>)request
{
    id<CKDownloadModelProtocol>  model=[_downloadingEntityOrdinalDic objectForKey:request.ck_url];
    void(^passedBlock)() = ^(){
        if(model)
        {
            model.downloadState=kDSDownloading;
            [self updateDataBaseWithModel:model];
            
            [self excuteStatusChangedBlock:request.ck_url];
        }
    };
    
    if(self.retryController)
    {
        [self.retryController retryWithModel:(id<CKDownloadModelProtocol,CKRetryModelProtocol>)model passed:^(id<CKDownloadModelProtocol> model) {
            passedBlock();
        } failed:^(id<CKDownloadModelProtocol> model) {
            
        }];
    }
    else
    {
        passedBlock();
    }
    
}

-(void) ck_request:(id<CKHTTPRequestProtocol>)request didReceiveResponseHeaders:(NSDictionary *)responseHeaders
{
    //record totol cotnent
    
    if([_downloadingEntityOrdinalDic objectForKey:request.ck_url])
    {
        long long fileLength = request.ck_totalContentLength;
        
        id<CKDownloadModelProtocol>  model=[_downloadingEntityOrdinalDic objectForKey:request.ck_url];
        model.totalCotentSize=fileLength;
        [self updateDataBaseWithModel:model];
    }
}


-(void) ck_requestFinished:(id<CKHTTPRequestProtocol>)request
{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        id<CKDownloadModelProtocol>  model=[_downloadingEntityOrdinalDic objectForKey:request.ck_url];
        if(model)
        {
            if(self.fileValidator)
            {
                [self.fileValidator validateFileSizeWithModel:(id<CKValidatorModelProtocol,CKDownloadModelProtocol>)model completeBlock:^(CKDownloadFileValidator *validator, id<CKValidatorModelProtocol,CKDownloadModelProtocol> model, BOOL isSucessful) {
                    [validator validateFileContentWithModel:model completeBlock:^(CKDownloadFileValidator *validator, id<CKValidatorModelProtocol,CKDownloadModelProtocol> model, BOOL isSucessful) {
                        [self downloadSuccesfulWithModel:model request:request];
                    }];
                }];
            }
            else
            {
                [self downloadSuccesfulWithModel:model request:request];
            }
        }

    });

    
}



-(void) ck_requestFailed:(id<CKHTTPRequestProtocol>)request
{
    
}


-(void) ck_request:(id<CKHTTPRequestProtocol>)request didReceiveBytes:(long long)bytes
{
    long long currentSize=request.ck_downloadBytes;

    NSTimeInterval oldTime=[[_currentTimeDic objectForKey:request.ck_url] doubleValue];
    NSTimeInterval currentTime=[NSDate timeIntervalSinceReferenceDate];
    
    CKDownloadSpeedAverageQueue * speedQueue=[_currentDownloadSizeDic objectForKey:request.ck_url];
    if(!speedQueue)
    {
        speedQueue=[[CKDownloadSpeedAverageQueue alloc] init];
        speedQueue.intervalLength=10;
        
        [_currentDownloadSizeDic setObject:speedQueue forKey:request.ck_url];
    }
    

    long long fileLength = request.ck_totalContentLength;
    
    CGFloat speed = speedQueue.speed;
    
    if(currentTime - oldTime > 1 || oldTime ==0)
    {
  
        [speedQueue pushCurrentDownloadSize:currentSize];
        [speedQueue pushCurrentDownloadTime:currentTime];
        
        speed = (oldTime==0? currentSize : speedQueue.speed);
        
        [_currentTimeDic setObject:[NSNumber numberWithDouble:currentTime] forKey:request.ck_url];
    }
    
    [self excuteProgressChangedBlock:currentSize totoalSize:fileLength speed:speed url:request.ck_url];
    

}


#pragma mark - dynamic method
-(NSArray*) downloadEntities
{
    if(self.downloadFilter)
    {
        return [_filterDownloadingEntities copy];
    }
    return  _downloadingEntityOrdinalDic.array;
}

-(NSArray*) downloadCompleteEntities
{
    if(self.downloadFilter)
    {
        return [_filterDownloadCompleteEntities copy];
    }
    return  _downloadCompleteEntityOrdinalDic.array;
}


-(BOOL) isAllDownloading
{
    return  [_pauseCountManager  isAllDownloading];
}

-(BOOL) isHasDownloading
{
    return ![self isAllPaused];
}

#pragma mark -  Notification
-(void) applicationWillEnterForeground
{
    if([self isWifi])
    {
        [self resumAllWithAutoResum:YES];
    }
}

-(void) applicationWillTerminate
{
    for (id<CKHTTPRequestProtocol> emRequest in _operationsDic.allValues) {
        [emRequest ck_clearDelegatesAndCancel];
    }
}

@end
