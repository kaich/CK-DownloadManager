//
//  CKHTTPRequestQueue.h
//  chengkai
//
//  Created by mac on 15/8/10.
//  Copyright (c) 2015年 chengkai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKHTTPRequestProtocal.h"

@protocol CKHTTPRequestQueueProtocal <NSObject>
/**
 *  Max concurrent operation Count. You can return IN_MAX if http lib may not support this feature.
 */
@property(nonatomic,assign) NSInteger ck_maxConcurrentOperationCount;
/**
 *  It refers to operations of NSOperation. If it's not kind of NSOperation, you can return []
 */
@property(nonatomic,strong,readonly) NSArray * ck_operations;
/**
 *  it refers to isSuspended of NSOperation. May remove in future
 */
@property(nonatomic,assign,readonly) BOOL ck_isSuspended;

/**
 *  create download request queue
 *
 *  @return queue
 */
+(instancetype) ck_createQueue;

/**
 *  add request to queue
 */
-(void) ck_addRequest:(id<CKHTTPRequestProtocal>) request;

/**
 *  set sespend
 *
 *  @param isSuspend
 */
-(void) ck_setSuspended:(BOOL) isSuspend;

/**
 *  start queue
 */
-(void) ck_go;
@end
