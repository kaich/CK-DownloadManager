//
//  CKDownloadPlistFactory.m
//  DownloadManager
//
//  Created by Mac on 14-6-6.
//  Copyright (c) 2014年 Mac. All rights reserved.
//

#import "CKDownloadPlistFactory.h"
#import "CKDownloadPathManager.h"

#define ITEMS_KEY @"items"
#define ASSETS_KEY @"assets"
#define URL_KEY  @"url"

#define REPLACE_MASK @"[FILE_NAME]"

#define  DIRECTORY_NAME @"Download"



@implementation CKDownloadPlistFactory

+(void) createPlistWithURL:(NSURL *)url iconImageURL:(NSURL *)imageURL
{
    NSDictionary * plistDic =[self getPlistDataWithUrl:url imageURL:imageURL];
    NSString * finalPath=[self getFinalPath:url];
    [self writeFileToPath:finalPath data:plistDic];
}


#pragma mark -  private method


+(NSMutableDictionary*) originalPlistWithUrl:(NSURL *) url
{
    
    NSString * toPath=nil;
    NSString * tmpPath=nil;
    [CKDownloadPathManager SetURL:url toPath:&toPath tempPath:&tmpPath];
    
    NSMutableDictionary * plistData=[NSMutableDictionary dictionaryWithContentsOfFile:toPath];
    
    return  plistData;
}


+(NSDictionary*) getPlistDataWithUrl:(NSURL*) url imageURL:(NSURL*) imageURL
{
    NSString * name= [url lastPathComponent];
    
    NSMutableDictionary * rootDic=[self originalPlistWithUrl:url];
    NSMutableArray * items=[rootDic objectForKey:ITEMS_KEY];
    NSMutableDictionary * item0=items[0];
    NSMutableArray * assets=[item0 objectForKey:ASSETS_KEY];
    
    //0
    NSMutableDictionary * asset0=assets[0];
    NSString * finalURL=[NSString stringWithFormat:@"%@%@",BaseInstallURL,name];
    [asset0 setObject:finalURL forKey:URL_KEY];

    //1
    NSMutableDictionary * assert1=assets[1];
    NSString * finialDisplayImageUrl=[NSString stringWithFormat:@"%@%@",BaseInstallURL,[imageURL lastPathComponent]];
    [assert1 setObject:finialDisplayImageUrl forKey:URL_KEY];
    
    //2
    NSMutableDictionary * assert2=assets[2];
    [assert2 setObject:finialDisplayImageUrl forKey:URL_KEY];
    
    return  rootDic;
}

+(NSString *) getFinalDirectoryPath
{
    
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject];
    NSString * finalPath=[documentsDirectory stringByAppendingPathComponent:DIRECTORY_NAME];
    return  finalPath;
}

+(NSString *) getFinalPath:(NSURL * ) url
{
    NSString * name= [url lastPathComponent];
    NSString * finalName=[[name stringByDeletingPathExtension] stringByAppendingPathExtension:@"plist"];
    NSString * finalPath=[[self getFinalDirectoryPath] stringByAppendingPathComponent:finalName];
    
    return finalPath;
}

+(void) writeFileToPath:(NSString*) filePath data:(NSDictionary*) dataDic
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self getFinalDirectoryPath] isDirectory:nil]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:[self getFinalDirectoryPath] withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    
    [dataDic writeToFile:filePath atomically:YES];
}

@end
