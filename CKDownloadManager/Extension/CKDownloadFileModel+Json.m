//
//  CKDownloadFileModel+Json.m
//  aisiweb
//
//  Created by Mac on 14-6-20.
//  Copyright (c) 2014年 weiaipu. All rights reserved.
//

#import "CKDownloadFileModel+Json.h"

#define  CHECK_NIL(_x_) _x_ ? _x_ : @""

#define FILE_MODEL_TITLE @"title"
#define FILE_MODEL_URL @"URLString"
#define FILE_MODEL_IMAGE @"imgURLString"
#define FILE_MODEL_FINAL_PATH @"downloadFinalPath"
#define FILE_MODEL_TOTAL_SIZE @"totalCotentSize"
#define FILE_MODEL_DOWNLOAD_SIZE @"downloadContentSize"
#define FILE_MODEL_COMPLTE_STATE @"completeState"
#define FILE_MODEL_APP_URL @"appURL"
#define FILE_MODEL_PLIST_URL @"plistURL"
#define FILE_MODEL_PLIST_IMAGE_URL @"plistImageURL"
#define FILE_MODEL_VERSION @"fileVersion"
#define FILE_MODEL_DATE @"downloadDate"

@implementation CKDownloadFileModel (Json)


-(void) modelFromJson:(id) josnObject
{
    NSDictionary * rootDic=(NSDictionary *) josnObject;
    
    self.title=[rootDic objectForKey:FILE_MODEL_TITLE];
    self.URLString =[rootDic objectForKey:FILE_MODEL_URL];
    self.imgURLString=[rootDic objectForKey:FILE_MODEL_IMAGE];
    self.downloadFinalPath=[rootDic objectForKey:FILE_MODEL_FINAL_PATH];
    self.totalCotentSize=[rootDic objectForKey:FILE_MODEL_TOTAL_SIZE];
    self.downloadContentSize=[rootDic objectForKey:FILE_MODEL_DOWNLOAD_SIZE];
    self.downloadState=[[rootDic objectForKey:FILE_MODEL_COMPLTE_STATE] intValue];
    self.appURL=[rootDic objectForKey:FILE_MODEL_APP_URL];
    self.plistURL=[rootDic objectForKey:FILE_MODEL_PLIST_URL];
    self.plistImageURL=[rootDic objectForKey:FILE_MODEL_PLIST_IMAGE_URL];
    self.fileVersion=[rootDic objectForKey:FILE_MODEL_VERSION];
    self.downloadDate=[rootDic objectForKey:FILE_MODEL_DATE];
}


-(NSDictionary*) jsonDictionary
{
    return @{FILE_MODEL_TITLE: CHECK_NIL(self.title),
             FILE_MODEL_IMAGE : CHECK_NIL(self.imgURLString),
             FILE_MODEL_URL : CHECK_NIL(self.URLString),
             FILE_MODEL_FINAL_PATH : CHECK_NIL(self.downloadFinalPath),
             FILE_MODEL_TOTAL_SIZE : CHECK_NIL(self.totalCotentSize),
             FILE_MODEL_DOWNLOAD_SIZE : CHECK_NIL(self.downloadContentSize),
             FILE_MODEL_COMPLTE_STATE : @(self.downloadState),
             FILE_MODEL_APP_URL : CHECK_NIL(self.appURL),
             FILE_MODEL_PLIST_URL : CHECK_NIL(self.plistURL),
             FILE_MODEL_PLIST_IMAGE_URL : CHECK_NIL(self.plistImageURL),
             FILE_MODEL_VERSION : CHECK_NIL(self.fileVersion),
             FILE_MODEL_DATE : CHECK_NIL(self.downloadDate)};
}

@end
