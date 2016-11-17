//
//  CKDownloadRetryController.h
//  chengkai
//
//  Created by mac on 15/1/5.
//  Copyright (c) 2015年 chengkai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKDownloadModelProtocol.h"
#import "CKRetryModelProtocol.h"

@class CKDownloadManager;

typedef void(^RetryBaseBlock)(id<CKDownloadModelProtocol>);

@interface CKDownloadRetryController : NSObject
{
    NSInteger _resumCount;
}

@property(nonatomic,weak) CKDownloadManager * downloadManager;

/**
 *  retry max count.  almost is network problem
 */
@property(nonatomic,assign) NSInteger retryMaxCount;

/**
 *  need resum task count
 */
@property(nonatomic,readonly) NSInteger resumCount;

/**
 *  make task auto resum
 *
 *  @param model
 */
-(void) makeTaskAutoResum:(id<CKDownloadModelProtocol,CKRetryModelProtocol>) model;

/**
 *  cancel auto resum
 *
 *  @param model 
 */
-(void) cancelTaskAutoResum:(id<CKDownloadModelProtocol,CKRetryModelProtocol>) model;

/**
 *  judge task is auto resum
 *
 *  @param model
 *
 *  @return YES auto resum
 */
-(BOOL) isAutoResumWithModel:(id<CKDownloadModelProtocol,CKRetryModelProtocol>) model;


#pragma mark  - retry 

/**
 *  retry task
 *
 *  @param model
 *  @param passedBlock  < retry max count
 *  @param failureBlock > retry max count
 */
-(void) retryWithModel:(id<CKDownloadModelProtocol,CKRetryModelProtocol>) model  passed:(RetryBaseBlock) passedBlock  failed:(RetryBaseBlock) failureBlock;

/**
 *  reset retry count 0
 *
 *  @param model
 */
-(void) resetRetryCountWithModel:(id<CKDownloadModelProtocol,CKRetryModelProtocol>) model;

@end
