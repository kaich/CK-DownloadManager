//
//  CKDownloadBaseModel.m
//  DownloadManager
//
//  Created by Mac on 14-5-21.
//  Copyright (c) 2014年 Mac. All rights reserved.
//



#import "CKDownloadBaseModel.h"

@implementation CKDownloadBaseModel

-(id) init
{
    
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.restTime=[NSString stringWithFormat:@"%f",MAXFLOAT];
    
    return self;

}

-(DownloadState) downloadState
{
    int state=[self.completeState intValue];
    DownloadState  downloadState=kDSDownloading;
    switch (state) {
        case 0:
        {
            downloadState=kDSDownloading;
        }
            break;
        case 1:
        {
            downloadState=kDSDownloadComplete;
        }
            break;
        case 2:
        {
            downloadState=kDSDownloadPause;
        }
            break;
        case 3:
        {
            downloadState=kDSWaitDownload;
        }
            break;
            
        default:
            break;
    }
    
    return downloadState;
}



#pragma mark -  DB Mehtod


+(NSString *)getTableName
{
    return @"tb_downlod";
}

+(NSString *)getPrimaryKey
{
    return URL_LINK_STRING;
}



+(NSDictionary *)getTableMapping
{
    NSMutableDictionary * dic=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"title",DWONLOAD_ITME_NAME,@"URLString",URL_LINK_STRING,@"downloadFinalPath",FINAL_PATH_STRING,@"totalCotentSize",TOTAL_CONTENT_SIZE,@"completeState",IS_DOWNLOAD_COMPLETE,@"downloadContentSize",DOWNLOAD_CONTENT_SIZE,@"imgURLString",ICON_IMAGE_URL,@"restTime",DOWNLOAD_REST_TIME,nil];
    NSDictionary * additionPropertiesMapping=[self additionTableColumnMapping];
    if(additionPropertiesMapping.count>0)
    {
        [dic addEntriesFromDictionary:additionPropertiesMapping];
    }
    return dic;
}


+(int)getTableVersion
{
    return 1;
}

+(NSDictionary*) additionTableColumnMapping
{
    return  nil;
}

@end
