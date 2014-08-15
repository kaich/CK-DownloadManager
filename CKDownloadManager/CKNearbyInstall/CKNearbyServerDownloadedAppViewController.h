//
//  CKNearbyServerDownloadedAppViewController.h
//  aisiweb
//
//  Created by Mac on 14-6-23.
//  Copyright (c) 2014年 weiaipu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKNearbyService.h"

typedef void(^ServiceHaveAcceptConnectBlock)();

@interface CKNearbyServerDownloadedAppViewController : UIViewController
@property(nonatomic,strong) CKNearbyService * service;

@property(nonatomic,copy) ServiceHaveAcceptConnectBlock  connectedBlock;
@end
