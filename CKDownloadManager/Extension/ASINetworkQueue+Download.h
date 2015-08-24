//
//  ASINetworkQueue+Download.h
//  chengkai
//
//  Created by mac on 15/8/10.
//  Copyright (c) 2015年 chengkai. All rights reserved.
//

#import "ASINetworkQueue.h"
#import "CKHTTPRequestQueueProtocal.h"

@interface ASINetworkQueue (Download)<CKHTTPRequestQueueProtocal>
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
