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
#define  DOWNLOAD_STATE @"download_state"
#define  DWONLOAD_ITME_NAME @"download_item_name"
#define  ICON_IMAGE_URL @"icon_url"
#define  DOWNLOAD_REST_TIME  @"download_rest_time"
#define  DOWNLOAD_DEPENDENCY @"download_dependency_task"
#define  EXTRA_DOWNLOAD_DATA @"extra_download_data"


@interface CKDownloadBaseModel : NSObject<CKDownloadModelProtocal>
{
    NSArray * _dependencies;
}

/**
 *  download task name
 */
@property(nonatomic,strong) NSString * title;
/**
 *  image url
 */
@property(nonatomic,strong) NSString * imgURLString;
/**
 *  download task url string
 */
@property(nonatomic,strong) NSString * URLString;
/**
 *  download final path
 */
@property(nonatomic,strong) NSString * downloadFinalPath;
/**
 *  file total size (Byte)
 */
@property(nonatomic,assign) long long  totalCotentSize;
/**
 *  download file size (Byte)
 */
@property(nonatomic,assign) long long downloadContentSize;
/**
 *  download speed (Byte/s)
 */
@property(nonatomic,assign)  CGFloat speed;
/**
 *  download rest cotent waste time (s)
 */
@property(nonatomic,assign) NSTimeInterval restTime;
/**
 *  download task state. eg. downloading and pause
 */
@property(nonatomic,assign) DownloadState downloadState;
/**
 *  this task's dependencies. the object of array is NSURL
 */
@property(nonatomic,strong) NSArray * dependencies;
/**
 *  url strings  example   @"http.........,http.........." you can't use it directly
 */
@property(nonatomic,strong) NSString * dependenciesString;
/**
 *  download time
 */
@property(nonatomic,strong) NSDate * downloadTime;
/**
 *  extra data for different http lib
 */
@property(nonatomic,strong) NSData * extraDownloadData;
@end
