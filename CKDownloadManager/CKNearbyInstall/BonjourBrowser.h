//
//  BonjourBrowser.h
//  aisiweb
//
//  Created by Mac on 14-6-19.
//  Copyright (c) 2014年 weiaipu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^BrowseNewServiceBlock)(NSNetService * service,NSString * address);
typedef void(^BrowseRemoveServiceBlock)(NSNetService * service);

@interface BonjourBrowser : NSObject

@property(nonatomic,strong) NSMutableArray * servicesAry;

@property(nonatomic,copy) BrowseNewServiceBlock browseNewServiceBlock;
@property(nonatomic,copy) BrowseRemoveServiceBlock  browseRemoveServiceBlock;


-(void) browserDomain:(NSString*) domain type:(NSString *) type;
@end
