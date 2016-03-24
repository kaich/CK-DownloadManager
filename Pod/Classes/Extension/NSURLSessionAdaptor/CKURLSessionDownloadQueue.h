//
//  CKURLSessionDownloadQueue.h
//  Pods
//
//  Created by mac on 16/2/17.
//
//

#import <Foundation/Foundation.h>
#import "CKHTTPRequestQueueProtocal.h"
#import "NSURLSessionTask+Download.h"

@interface CKURLSessionDownloadQueue : NSObject<CKHTTPRequestQueueProtocal>

@property(nonatomic,strong) NSURLSession * session;

@property(nonatomic,assign) NSInteger ck_maxConcurrentOperationCount;

@property(nonatomic,strong,readonly) NSArray * ck_operations;

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
 *  start queue
 */
-(void) ck_go;
@end
