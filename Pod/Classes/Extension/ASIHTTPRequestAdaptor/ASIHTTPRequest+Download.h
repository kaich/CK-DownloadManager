//
//  ASIHTTPRequest+Download.h
//  chengkai
//
//  Created by mac on 15/1/7.
//  Copyright (c) 2015年 chengkai. All rights reserved.
//

#import "ASIHTTPRequest.h"
#import "CKHTTPRequestProtocal.h"
#import "CKDownloadManager.h"

@interface CKDownloadManager ()

-(id<CKHTTPRequestProtocal>) requestOnQueueWithURL:(NSURL *) url;

@end

@interface ASIHTTPRequest (Download)<CKHTTPRequestProtocal>

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
 *  add dependency request
 *
 *  @param request
 */
-(void) ck_addDependency:(id) request;

@end
