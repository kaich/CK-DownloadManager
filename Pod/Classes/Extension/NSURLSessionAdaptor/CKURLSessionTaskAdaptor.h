//
//  NSURLSessionTask+Download.h
//  Pods
//
//  Created by mac on 16/3/23.
//
//

#import <Foundation/Foundation.h>
#import "CKURLDownloadTaskProtocol.h"

@interface CKURLSessionTaskAdaptor : NSObject<CKURLDownloadTaskProtocol>

/**
 invoke to end a operation
 */
- (void)completeOperation;

+(NSData *) __changeResumDataWithData:(NSData *) data url:(NSURL *) url;

+ (void) __copyTempPathWithResumData:(NSData *) data url:(NSURL *) url;


//MARK: -  CKURLDownloadTaskProtocol

//block to execute when headers are received
@property(nonatomic,copy) CKBasicBlock headersReceivedBlock;

//block to execute when request completes successfully
@property(nonatomic,copy) CKBasicBlock completionBlock;

//block to execute when request fails
@property(nonatomic,copy) CKBasicBlock failureBlock;

//block for when bytes are received
@property(nonatomic,copy) CKBasicBlock bytesReceivedBlock;

/**
 *  download total bytes
 */
@property(nonatomic,readonly) long long ck_downloadBytes;

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

