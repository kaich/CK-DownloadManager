//
//  MainXmlOperation.h
//  i4Connect
//
//  Created by Alan on 13-12-6.
//  Copyright (c) 2013年 weiaipu. All rights reserved.
//广告和应用列表数据解析

#import <Foundation/Foundation.h>
#import "AppListRecord.h"
//block 
@interface MainXmlOperation : NSOperation
@property (nonatomic, copy) void (^errorHandler)(NSError *error);
@property (nonatomic, strong) NSMutableArray *appRecordList;
- (id)initWithData:(NSData *)data;
@end
