//
//  CKHTTPRequestProtocal.h
//  aisiweb
//
//  Created by mac on 15/1/7.
//  Copyright (c) 2015年 weiaipu. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSUInteger, CKHTTPRequestStatus) {
    kRSFinished,
    kRSCanceled,
    kRSExcuting,
    kRSReady
};


@protocol CKHTTPRequestProtocal;

@protocol CKHTTPRequestDelegate <NSObject>

/**
 *  invoke when request start
 *
 *  @param request
 */
-(void) ck_requestStarted:(id<CKHTTPRequestProtocal>)request;

/**
 *  invoke when request get response
 *
 *  @param request
 *  @param responseHeaders
 */
-(void) ck_request:(id<CKHTTPRequestProtocal>)request didReceiveResponseHeaders:(NSDictionary *)responseHeaders;

/**
 *  invoke when request finish
 *
 *  @param request
 */
-(void) ck_requestFinished:(id<CKHTTPRequestProtocal>)request;

/**
 *  invoke when request failed
 *
 *  @param request
 */
-(void) ck_requestFailed:(id<CKHTTPRequestProtocal>)request;

/**
 *  invoke when request receive bytes
 *
 *  @param request
 *  @param bytes
 */
-(void) ck_request:(id<CKHTTPRequestProtocal>)request didReceiveBytes:(long long)bytes;

@end


@protocol CKHTTPRequestProtocal <NSObject>

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
 *  request header  contentLength .  rest content bytes
 */
@property(nonatomic,readonly) long long ck_contentLength;

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



