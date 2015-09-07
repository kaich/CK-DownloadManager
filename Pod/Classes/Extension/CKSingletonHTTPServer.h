//
//  CKSingletonHTTPServer.h
//  chengkai
//
//  Created by Mac on 14-6-23.
//  Copyright (c) 2014年 chengkai. All rights reserved.
//

#import "HTTPServer.h"

#define APP_KEY @"app_key_for_txt"

@interface CKSingletonHTTPServer : HTTPServer

@property(nonatomic,readonly) NSString * serviceNameIdentifier;

+ (instancetype)sharedInstance;

-(void) go;
@end
