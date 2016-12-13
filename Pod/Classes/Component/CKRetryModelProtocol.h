//
//  CKRetryModelProtocol.h
//  chengkai
//
//  Created by mac on 15/1/5.
//  Copyright (c) 2015年 chengkai. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CKRetryModelProtocol <NSObject>

/**
 *  judge is need resum
 */
@property(nonatomic,assign) BOOL isNeedResumWhenNetWorkReachable;

/**
 *  retry current count
 */
@property(nonatomic,assign) NSInteger  retryCount;

/**
 *  retry head length current count
 */
@property(nonatomic,assign) NSInteger  headLengthRetryCount;

@end
