//
//  CKURLDownloadTaskProtocol.h
//  Pods
//
//  Created by mac on 16/12/16.
//
//

#import <Foundation/Foundation.h>

typedef void (^CKBasicBlock)(void);
typedef void (^CKHeadersBlock)(NSDictionary *responseHeaders);
typedef void (^CKSizeBlock)(long long size);
typedef void (^CKProgressBlock)(unsigned long long size, unsigned long long total);
typedef void (^CKDataBlock)(NSData *data);
typedef void (^CKErrorBlock)(NSError *data);

@protocol CKURLDownloadTaskProtocol <NSObject>

@property(nonatomic,copy) CKBasicBlock startedBlock;

//block to execute when headers are received
@property(nonatomic,copy) CKHeadersBlock headersReceivedBlock;

//block to execute when request completes successfully
@property(nonatomic,copy) CKBasicBlock completionBlock;

//block to execute when request fails
@property(nonatomic,copy) CKErrorBlock failureBlock;

//block for when bytes are received
@property(nonatomic,copy) CKProgressBlock bytesReceivedBlock;

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
 create new instance

 @return instance
 */
+(instancetype) create;

/**
 *  start download request
 *
 *  @return request
 */
-(void) ck_startDownloadRequestWithURL:(NSURL *) url;

/**
 *  start head request
 *
 *  @return request
 */
-(void) ck_startHeadRequestWithURL:(NSURL *) url;

/**
 *  cancel request
 */
-(void) ck_clearDelegatesAndCancel;

@end
