//
//  CKHTTPRequestOperation.h
//  Pods
//
//  Created by mac on 16/12/16.
//
//

#import <Foundation/Foundation.h>
#import "CKHTTPRequestProtocol.h"


@interface CKHTTPRequestOperation : NSOperation<CKHTTPRequestProtocol>

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
