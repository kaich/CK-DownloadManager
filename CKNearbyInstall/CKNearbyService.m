//
//  CKNearbyService.m
//  aisiweb
//
//  Created by Mac on 14-6-23.
//  Copyright (c) 2014年 weiaipu. All rights reserved.
//

#import "CKNearbyService.h"

@implementation CKNearbyService

-(id) init
{
    
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.connectionState=kCSDisconnected;
    
    return self;

}

@end
