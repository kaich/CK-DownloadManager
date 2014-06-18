//
//  CKDownloadFileModel.m
//  DownloadManager
//
//  Created by Mac on 14-5-23.
//  Copyright (c) 2014年 Mac. All rights reserved.
//

#import "CKDownloadFileModel.h"
#define  TITLE  @"download_title"
#define  PLIST_URL @"download_plist_url"
#define  APP_VERSION @"download_app_version"
#define  APP_DOWNLOAD_DATE @"download_date"
#define  APP_PLIST_IMAGE_URL @"plist_image_url"


@implementation CKDownloadFileModel
@dynamic downloadDate;

 +(NSDictionary*)additionTableColumnMapping
{
    return @{
             PLIST_URL : @"plistURL",
             APP_VERSION : @"fileVersion",
             APP_DOWNLOAD_DATE :@"downloadDate",
             APP_PLIST_IMAGE_URL : @"plistImageURL" };
}



#pragma mark - download date 
-(void) setDownloadDate:(NSString *)downloadDate
{
    _downloadDate=downloadDate;
}

-(NSString *) downloadDate
{
    NSDate * currentDate=[NSDate date];
    NSDateFormatter * formater=[[NSDateFormatter alloc] init];
    [formater setDateFormat:@"yyyy-MM-dd"];
    
    _downloadDate=[formater stringFromDate:currentDate];
    
    return  _downloadDate;
}

@end
