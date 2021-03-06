//
//  NSURLSessionTask+Download.h
//  Pods
//
//  Created by mac on 16/3/23.
//
//

#import <Foundation/Foundation.h>
#import "CKHTTPRequestProtocol.h"

@interface CKURLSessionTaskRequest : NSOperation

/**
 Judge whether receiveResponseHeaders method called.
 */
@property(nonatomic,assign) BOOL isExecutedDidReceiveHeader;

@property(nonatomic,strong) NSURLSessionTask * task;

@property(nonatomic,assign) long long totalBytesWritten;

@property(nonatomic,assign) long long totalBytesExpectedToWrite;

@property(nonatomic,assign) BOOL isHead;

/**
 excute delegate receiveResponseHeaders method
 */
-(void) ck_performDelegateDidReceiveResponseHeaders;

/**
 invoke to end a operation
 */
- (void)completeOperation;

+(NSData *) __changeResumDataWithData:(NSData *) data url:(NSURL *) url;

+ (void) __copyTempPathWithResumData:(NSData *) data url:(NSURL *) url;


//MARK: -  CKHTTPRequestProtocol

/**
 *  request delegate
 */
@property(nonatomic,strong) id<CKHTTPRequestDelegate> ck_delegate;

/**
 *  request url
 */
@property(nonatomic,readonly) NSURL * ck_url;

/**
 *  download total bytes
 */
@property(nonatomic,readonly) long long ck_downloadBytes;

/**
 *  request header  contentLength .  rest content bytesCKURLSessionTaskRequest.
 */
@property(nonatomic,readonly) long long ck_contentLength;

/**
 *  total file length.
 */
@property(nonatomic,readonly) long long ck_totalContentLength;

/**
 *  request status
 */
@property(nonatomic,readonly) CKHTTPRequestStatus ck_status;

/**
 *  if temp path is visible, you can use  CKDownloadPathManager to get temp path. otherwise you can only
 *  get temp file size by ck_downloadBytes
 */
+ (BOOL) ck_isVisibleTempPath;


/**
 *  create download request
 *
 *  @return request
 */
+(instancetype) ck_createDownloadRequestWithURL:(NSURL *) url isHead:(BOOL) isHead;

/**
 *  wheter should continue when enter background
 *
 *  @param isNeed
 */
-(void) ck_setShouldContinueWhenAppEntersBackground:(BOOL) isNeed;

/**
 *  cancel request
 */
-(void) ck_clearDelegatesAndCancel;

/**
 *  suspend request
 */
-(void) ck_suspend;

/**
 *  pause request
 */
-(void) ck_resume;

/**
 *  add dependency request
 *
 *  @param request
 */
-(void) ck_addDependency:(id) request;


@end

