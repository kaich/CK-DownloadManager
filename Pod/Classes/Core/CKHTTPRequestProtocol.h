//
//  CKHTTPRequestProtocol.h
//  chengkai
//
//  实现该协议，
//  Created by mac on 15/1/7.
//  Copyright (c) 2015年 chengkai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKURLDownloadTaskProtocol.h"
@class CKDownloadManager;


typedef NS_ENUM(NSUInteger, CKHTTPRequestStatus) {
    kRSFinished,
    kRSCanceled,
    kRSExcuting,
    kRSReady,
    kRSSuspended,
};

@protocol CKHTTPRequestProtocol;

@protocol CKHTTPRequestDelegate <NSObject>

@required

/**
 *  invoke when request start
 *
 *  @param request
 */
-(void) ck_requestStarted:(id<CKHTTPRequestProtocol>)request;

/**
 *  invoke when request get response
 *
 *  @param request
 *  @param responseHeaders
 */
-(void) ck_requestDidReceiveResponseHeaders:(id<CKHTTPRequestProtocol>)request;

/**
 *  invoke when request finish
 *
 *  @param request
 */
-(void) ck_requestFinished:(id<CKHTTPRequestProtocol>)request;

/**
 *  invoke when request failed
 *
 *  @param request
 */
-(void) ck_requestFailed:(id<CKHTTPRequestProtocol>)request;

/**
 *  invoke when request receive bytes
 *
 *  @param request
 *  @param bytes
 */
-(void) ck_requestDidReceiveBytes:(id<CKHTTPRequestProtocol>)request;

@end


@protocol CKHTTPRequestProtocol <NSObject>

@required

/**
 *  request delegate
 */
@property(nonatomic,strong) id<CKHTTPRequestDelegate> ck_delegate;

/**
 download task
 */
@property(nonatomic,strong) Class<CKURLDownloadTaskProtocol> downloadTaskClass;

/**
 download manager
 */
@property(nonatomic,weak) CKDownloadManager * downloadManager;

/**
 *  request url 
 */
@property(nonatomic,readonly) NSURL * ck_url;

/**
 *  download total bytes
 */
@property(nonatomic,readonly) long long ck_downloadBytes;

/**
 *  request header  contentLength .  rest content bytes
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



