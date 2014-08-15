//
//  CKPathManager.h
//  DownloadManager
//
//  Created by Mac on 14-5-21.
//  Copyright (c) 2014年 Mac. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CKDownloadPathManager : NSObject
/**
 *  返回存储的文件路径
 *
 *  @param URL
 *  @param toPath  最终目录
 *  @param tmpPath 临时目录
 */
+(void) SetURL:(NSURL *) URL toPath:(NSString**) toPath  tempPath:(NSString**) tmpPath;

/**
 *  已经下载的大小
 *
 *  @param URL
 *
 *  @return 大小
 */
+(float) downloadContentSizeWithURL:(NSURL*) URL;

/**
 *  根据URL删除已经存在的文件
 *
 *  @param URL 
 */
+(void) removeFileWithURL:(NSURL*) URL;

@end
