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
#define  ICON_IMAGE_URL @"icon_url"
#define  DOWNLOAD_REST_TIME  @"download_rest_time"


@interface CKDownloadBaseModel : NSObject<CKDownloadModelProtocal>

//download item name
@property(nonatomic,strong) NSString * title;
//icon url
@property(nonatomic,strong) NSString * imgURLString;
//download url string
@property(nonatomic,strong) NSString * URLString;
//download final path
@property(nonatomic,strong) NSString * downloadFinalPath;
//file total size
@property(nonatomic,strong) NSString * totalCotentSize;
//download file size
@property(nonatomic,strong) NSString * downloadContentSize;
//download speed;
@property(nonatomic,strong) NSString * speed;
//download rest cotent waste time
@property(nonatomic,strong) NSString * restTime;
//1downloading 0 complete  2 pause  3 wait
@property(nonatomic,strong) NSString * completeState;
@property(nonatomic,readonly,assign) DownloadState downloadState;
//this task's dependency , the object of array is NSURL
@property(nonatomic,strong) NSArray * dependencies;
@end
