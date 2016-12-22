//
//  CKPathManager.h
//  DownloadManager
//
//  由于NSURLSessionTask的临时路径是不定的，因此把临时路径存到Model里面
//  Created by Mac on 14-5-21.
//  Copyright (c) 2014年 Mac. All rights reserved.
//  

#import <Foundation/Foundation.h>

typedef NSString *(^PathGenerateBlock)(NSURL * url);

@interface CKDownloadPathManager : NSObject
//path genertate algorithm
@property(nonatomic,copy) PathGenerateBlock toPathBlock;
@property(nonatomic,copy) PathGenerateBlock tmpPathBlock;

/**
 *  单例
 *
 *  @return Instance
 */
+ (instancetype)sharedInstance;

/**
 *  返回存储的文件路径
 *
 *  @param URL
 *  @param toPath  最终目录
 *  @param tmpPath 临时目录
 */
-(void) getURL:(NSURL *) URL toPath:(NSString**) toPath  tempPath:(NSString**) tmpPath;

/**
 *  返回存储的文件路径
 *
 *  @param URL
 *  @param toPath  最终目录
 *  @param tmpPath 临时目录
 */
-(void) setURL:(NSURL *) URL toPath:(NSString*) toPath  tempPath:(NSString*) tmpPath;

/**
 *  已经下载的大小
 *
 *  @param URL
 *
 *  @return 大小
 */
-(long long) downloadContentSizeWithURL:(NSURL*) URL;

/**
 *  根据URL删除已经存在的文件
 *
 *  @param URL 
 */
-(void) removeFileWithURL:(NSURL*) URL;

/**
 *  移动文件从最终目录到临时目录
 *
 *  @param URL 
 */
-(void) moveFinalPathToTmpPath:(NSURL*) URL;

@end
