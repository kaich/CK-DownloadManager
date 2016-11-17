//
//  CKDownloadModelProtocol.h
//  DownloadManager
//
//  Created by Mac on 14-5-23.
//  Copyright (c) 2014年 Mac. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    kDSDownloading,
    kDSDownloadComplete,
    kDSDownloadPause,
    kDSWaitDownload,
    kDSDownloadErrorFinalLength,
    kDSDownloadErrorResum,
    kDSDownloadErrorContent,
    kDSDownloadErrorUnknow
}DownloadState;

@protocol CKDownloadModelProtocol <NSObject>

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

@optional
/**
 *  addtion mapping, implement by subclass
 *
 *  @return new properties mapping
 */
+(NSDictionary * ) additionTableColumnMapping;

@end
