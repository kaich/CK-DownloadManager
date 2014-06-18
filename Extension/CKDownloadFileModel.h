//
//  CKDownloadFileModel.h
//  DownloadManager
//
//  Created by Mac on 14-5-23.
//  Copyright (c) 2014年 Mac. All rights reserved.
//

#import "CKDownloadBaseModel.h"

@interface CKDownloadFileModel : CKDownloadBaseModel<CKDownloadModelProtocal>
{
    NSString * _downloadDate;
}
@property(nonatomic,strong) NSString * plistURL;
@property(nonatomic,strong) NSString * plistImageURL;
@property(nonatomic,strong) NSString * fileVersion;
@property(nonatomic,strong) NSString * downloadDate;
@end
