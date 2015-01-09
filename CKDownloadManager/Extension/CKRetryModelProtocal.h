//
//  CKRetryModelProtocal.h
//  aisiweb
//
//  Created by mac on 15/1/5.
//  Copyright (c) 2015年 weiaipu. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CKRetryModelProtocal <NSObject>

/**
 *  judge is need resum
 */
@property(nonatomic,assign) BOOL isNeedResumWhenNetWorkReachable;

/**
 *  retry current count
 */
@property(nonatomic,assign) int  retryCount;

@end
