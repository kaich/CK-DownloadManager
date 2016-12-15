//
//  ASINetworkQueue+Download.h
//  chengkai
//
//  Created by mac on 15/8/10.
//  Copyright (c) 2015年 chengkai. All rights reserved.
//

#import "ASINetworkQueue.h"
#import "CKHTTPRequestQueueProtocol.h"

@interface ASINetworkQueue (Download)<CKHTTPRequestQueueProtocol>

@property(nonatomic,assign) NSInteger ck_maxConcurrentOperationCount;

@property(nonatomic,strong,readonly) NSArray * ck_operations;

@property(nonatomic,assign,readonly) BOOL ck_isSuspended;

/**
 *  create download request queue
 *
 *  @return queue
 */
+(instancetype) ck_createQueue:(BOOL) isHead;

/**
 *  add request to queue
 */
-(void) ck_addRequest:(id<CKHTTPRequestProtocol>) request;

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
