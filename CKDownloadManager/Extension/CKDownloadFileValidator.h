//
//  CKDwonalodFileValidator.h
//  aisiweb
//
//  Created by mac on 14/12/16.
//  Copyright (c) 2014年 weiaipu. All rights reserved.
//
//  Validate Download File . remember to call  pauseCountIncrease method when validate failed.

#import <Foundation/Foundation.h>
#import "CKDownloadManager.h"
#import "CKDownloadModelProtocal.h"

@class CKDownloadFileValidator;
typedef void(^DownloadFileValidateCompleteBlock)(CKDownloadFileValidator * validator ,id<CKDownloadModelProtocal> model , BOOL isSucessful);

@interface CKDownloadFileValidator : NSObject

@property(nonatomic,weak) CKDownloadManager * downloadManager;

/**
 *  validate download file size
 *
 *  @model  download task model
 *  @param completeBlock  block called when validate complete
 */
-(void) validateFileSizeWithModel:(id<CKDownloadModelProtocal>) model completeBlock:(DownloadFileValidateCompleteBlock) completeBlock;

/**
 *  validate download file content
 *
 *  @model  download task model
 *  @param completeBlock block called when validate complete
 */
-(void) validateFileContentWithModel:(id<CKDownloadModelProtocal>) model completeBlock:(DownloadFileValidateCompleteBlock) completeBlock;

/**
 *  validate download file request header content size (only apply when no IfModifiedCache condition)
 *
 *  @model  download task model
 *  @param times         retry times
 *  @param completeBlock block called when validate complete
 */
-(void) validateFileHeaderWithModel:(id<CKDownloadModelProtocal>) model headerFileLength:(long long) fileLength times:(NSUInteger) times completeBlock:(DownloadFileValidateCompleteBlock) completeBlock;
@end
