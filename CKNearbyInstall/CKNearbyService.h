//
//  CKNearbyService.h
//  aisiweb
//
//  Created by Mac on 14-6-23.
//  Copyright (c) 2014年 weiaipu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum{
    kCSConnected,
    kCSDisconnected
}ConnectionState;

@interface CKNearbyService : NSObject
@property(nonatomic,strong) NSString * name;
@property(nonatomic,strong) NSString * address;
@property(nonatomic,strong) NSString * serviceIdentifier;

//连接状态
@property(nonatomic,assign) ConnectionState connectionState;
@end
