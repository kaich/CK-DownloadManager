//
//  NSURLSessionTask+Download.h
//  Pods
//
//  Created by mac on 16/3/23.
//
//

#import <Foundation/Foundation.h>
#import "CKHTTPRequestProtocal.h"

@interface NSURLSessionTask (Download)<CKHTTPRequestProtocal>

@property(nonatomic,assign) BOOL isExecutedDidReceiveHeader;

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
 *  request header  contentLength .  rest content bytes.
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
+(instancetype) ck_createDownloadRequestWithURL:(NSURL *) url;

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


-(void) ck_performDelegateDidReceiveResponseHeaders;

@end

