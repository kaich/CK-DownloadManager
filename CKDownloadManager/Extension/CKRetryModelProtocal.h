//
//  CKRetryModelProtocal.h
//  aisiweb
//
//  Created by mac on 15/1/5.
//  Copyright (c) 2015年 weiaipu. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CKRetryModelProtocal <NSObject>

@property(nonatomic,assign) BOOL isNeedResumWhenNetWorkReachable;

@property(nonatomic,assign) int  retryCount;

@end
