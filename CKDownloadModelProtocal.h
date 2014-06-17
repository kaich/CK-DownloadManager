//
//  CKDownloadModelProtocal.h
//  DownloadManager
//
//  Created by Mac on 14-5-23.
//  Copyright (c) 2014年 Mac. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    kDSDownloading,
    kDSDownloadComplete,
    kDSDownloadPause
}DownloadState;

@protocol CKDownloadModelProtocal <NSObject>

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
//1downloading 0 complete  2pause
@property(nonatomic,strong) NSString * completeState;
@property(nonatomic,readonly,assign) DownloadState downloadState;

@optional
//new properties mapping
+(NSDictionary * ) additionTableColumnMapping;

@end
