//
//  CKHTTPRequestQueue.h
//  chengkai
//
//  Created by mac on 15/8/10.
//  Copyright (c) 2015年 chengkai. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CKHTTPRequestQueueProtocal <NSObject>

/**
 *  create download request queue
 *
 *  @return queue
 */
+(instancetype) ck_createQueue;

/**
 *  start queue
 */
-(void) ck_go;
@end
