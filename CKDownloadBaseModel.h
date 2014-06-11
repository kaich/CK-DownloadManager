//
//  CKDownloadBaseModel.h
//  DownloadManager
//  inheritance this class to add your own information.
//  Created by Mac on 14-5-21.
//  Copyright (c) 2014年 Mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKDownloadModelProtocal.h"

#define  URL_LINK_STRING @"download_url"
#define  FINAL_PATH_STRING @"download_final_path"
#define  TOTAL_CONTENT_SIZE @"total_cotent_size"
#define  DOWNLOAD_CONTENT_SIZE @"download_content_size"
#define  IS_DOWNLOAD_COMPLETE @"download_complete_state"
#define  DWONLOAD_ITME_NAME @"download_item_name"


@interface CKDownloadBaseModel : NSObject<CKDownloadModelProtocal>

//download item name
@property(nonatomic,strong) NSString * title;
//download url string
@property(nonatomic,strong) NSString * URLString;
//download final path
@property(nonatomic,strong) NSString * downloadFinalPath;
//file total size
@property(nonatomic,strong) NSString * totalCotentSize;
//download file size
@property(nonatomic,strong) NSString * downloadContentSize;
//1downloading 0 complete  2pause
@property(nonatomic,strong) NSString * completeState;
@property(nonatomic,readonly,assign) DownloadState downloadState;

@end
