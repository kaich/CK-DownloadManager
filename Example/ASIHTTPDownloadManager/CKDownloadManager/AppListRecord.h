//
//  AppListRecord.h
//  i4Connect
//
//  Created by waipmac02 on 13-12-6.
//  Copyright (c) 2013年 weiaipu. All rights reserved.
//广告和应用列表数据模型

#import <Foundation/Foundation.h>

@protocol AppItemDelegate <NSObject>

@property (nonatomic, strong)NSString *minversion;
@property (nonatomic, assign)long long sizebyte;

@optional
@property(nonatomic,strong)NSString *appName;

@property(nonatomic,strong) NSString *itemId;
@property(nonatomic,strong)NSString *appId;
@property(nonatomic,strong)NSString *plist;
@property (nonatomic, assign)int pkageType;



@end


@interface AppListRecord : NSObject<AppItemDelegate>
@property(nonatomic,strong)NSString *appId;
@property(nonatomic,strong)NSString *appName;
@property(nonatomic,strong) UIImage *iconImg;
@property(nonatomic,strong)NSString *sLogan;
@property(nonatomic,strong)NSString *sLoganColor;
@property(nonatomic,strong)NSString *icon;
@property(nonatomic,strong)NSString *version;
@property(nonatomic,strong)NSString *size;
@property(nonatomic,strong)NSString *path;
@property(nonatomic,strong)NSString *itemId;
@property(nonatomic,strong)NSString *sourceid;
@property(nonatomic,strong)NSString *downLoaded;
@property(nonatomic,strong)NSString *plist;
@property (nonatomic, strong) UIButton *xiazaiButton;
@property (nonatomic, strong)NSString *local;
@property (nonatomic, assign)BOOL  isCheck;
@property (nonatomic, assign)int pkageType;
@property (nonatomic, strong)NSString *buyuseid;
@property (nonatomic, strong)NSString* appprice;
@property (nonatomic,assign)BOOL   isDownLoad;
@property (nonatomic, assign)long long sizebyte;
@property (nonatomic, strong)NSString *minversion;
@property (nonatomic, strong)NSString *isfull;

@end

@interface ADListRecord : NSObject<AppItemDelegate>
@property(nonatomic,strong)NSString *adid;
@property(nonatomic,strong)NSString *name;
@property(nonatomic,strong)NSString *type;
@property(nonatomic,strong)NSString *image;
@property(nonatomic,strong)NSString *appId;
@property(nonatomic,strong)NSString *appUrl;
@property(nonatomic,strong)NSString *itemId;
@property(nonatomic,strong)NSString *plist;
@property(nonatomic,strong)NSString *special;
@property(nonatomic, strong)NSString *local;
@property(nonatomic, strong)NSString *version;
@property(nonatomic, strong)NSString *size;
@property(nonatomic,strong)NSString *sourceid;
@property(nonatomic,strong)NSString *icon;
@property (nonatomic, assign)int pkageType;
@property (nonatomic, assign)long long sizebyte;
@property (nonatomic, strong)NSString *minversion;

@end