//
//  CKDownloadFileModel.h
//  DownloadManager
//
//  Created by Mac on 14-5-23.
//  Copyright (c) 2014年 Mac. All rights reserved.
//

#import "CKDownloadBaseModel.h"
#import "CKValidatorModelProtocol.h"
#import "CKRetryModelProtocol.h"

@interface CKDownloadFileModel : CKDownloadBaseModel<CKDownloadModelProtocol,CKDownloadModelProtocol,CKRetryModelProtocol>
{
    NSString * _downloadDate;
}
@property(nonatomic,strong) NSString * appURL;
@property(nonatomic,strong) NSString * plistURL;
@property(nonatomic,strong) NSString * plistImageURL;
@property(nonatomic,strong) NSString * fileVersion;
@property(nonatomic,strong) NSString * downloadDate;
@property(nonatomic,strong) NSString * address;

@property(nonatomic,assign) long long standardFileSize;
@property(nonatomic,strong) NSString * standardFileValidationCode;

@property(nonatomic,assign) BOOL isNeedResumWhenNetWorkReachable;
@property(nonatomic,assign) NSInteger  retryCount;
@property(nonatomic,assign) NSInteger  headLengthRetryCount;


@end
