//
//  CKDownloadPlistFactory.h
//  DownloadManager
//
//  Created by Mac on 14-6-6.
//  Copyright (c) 2014年 Mac. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface CKDownloadPlistFactory : NSObject
/**
 *  创建plist 文件
 *
 *  @param url 地址
 */
+(void) createPlistWithURL:(NSURL *)url iconImageURL:(NSURL *)imageURL appURL:(NSURL *)appURL  baseURL:(NSString *) baseURL;

@end
