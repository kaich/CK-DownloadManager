//
//  ShareXmlParser.h
//  aisiweb
//
//  Created by Alan on 14-3-19.
//  Copyright (c) 2014年 weiaipu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MainXmlOperation.h"

@interface ShareXmlParser : NSObject<NSURLConnectionDataDelegate>

@property (nonatomic, copy) void (^failHandler)(NSError *error);
@property (nonatomic, copy) void (^SuccessHandler)(NSArray *ary1,NSArray *ary2);

- (void)startRequestWithUrl:(NSString *)urlStr;
@end
