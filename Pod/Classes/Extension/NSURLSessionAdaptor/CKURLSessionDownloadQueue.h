//
//  CKURLSessionDownloadQueue.h
//  Pods
//
//  Created by mac on 16/2/17.
//
//

#import <Foundation/Foundation.h>
#import "CKHTTPRequestQueueProtocol.h"


@interface CKURLSessionDownloadQueue : NSOperationQueue<CKHTTPRequestQueueProtocol>

@property(nonatomic,strong) NSURLSession * session;

@property(nonatomic,assign) NSInteger ck_maxConcurrentOperationCount;

@property(nonatomic,strong,readonly) NSArray * ck_operations;

@property(nonatomic,assign,readonly) BOOL ck_isSuspended;

@property(nonatomic,assign,readonly) BOOL isHead;

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
 *  start queue
 */
-(void) ck_go;
@end
