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
#import "CKHTTPRequestProtocol.h"

@class CKDownloadManager;

typedef void(^CKRetryBaseBlock)(id<CKDownloadModelProtocol>);

@interface CKDownloadRetryController : NSObject
{
    NSInteger _resumCount;
}

@property(nonatomic,weak) CKDownloadManager * downloadManager;

/**
 *  retry max count.  almost is network problem
 */
@property(nonatomic,assign) NSInteger headLengthRetryMaxCount;

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


@end
