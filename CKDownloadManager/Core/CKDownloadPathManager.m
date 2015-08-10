//
//  CKPathManager.m
//  DownloadManager
//
//  Created by Mac on 14-5-21.
//  Copyright (c) 2014年 Mac. All rights reserved.
//

#import "CKDownloadPathManager.h"

typedef enum {
    kPTTemporary,
    kPTFinnal
}PathType;

@implementation CKDownloadPathManager

+(void) SetURL:(NSURL *) URL toPath:(NSString *__autoreleasing *)toPath tempPath:(NSString *__autoreleasing *)tmpPath
{
    *tmpPath=[self downloadPathWithURL:URL type:kPTTemporary];
    *toPath=[self downloadPathWithURL:URL type:kPTFinnal];
}


+(long long) downloadContentSizeWithURL:(NSURL *)URL
{
    NSString * path=[self downloadPathWithURL:URL type:kPTTemporary];
    long long contentSize = 0;
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        path=[self downloadPathWithURL:URL type:kPTFinnal];
    }
    
    contentSize=[self fileSizeForPath:path];
    return contentSize;
}


+(void) removeFileWithURL:(NSURL *)URL
{
    NSString *tmpPath=[self downloadPathWithURL:URL type:kPTTemporary];
    NSString *toPath=[self downloadPathWithURL:URL type:kPTFinnal];
    
    NSError * error=nil;
    NSFileManager * mgr=[NSFileManager new];
    if([mgr fileExistsAtPath:tmpPath])
    {
        [mgr removeItemAtPath:tmpPath error:&error];
        if(error)
            NSLog(@"delete tempory file failed ==> %@",error);
    }
    
    if([mgr fileExistsAtPath:toPath])
    {
        [mgr removeItemAtPath:toPath error:&error];
        if(error)
            NSLog(@"delete tempory file failed ==> %@",error);
    }
}


+(void) moveFinalPathToTmpPath:(NSURL*) URL
{
    NSString *tmpPath=[self downloadPathWithURL:URL type:kPTTemporary];
    NSString *toPath=[self downloadPathWithURL:URL type:kPTFinnal];
    
    NSError * error=nil;
    NSFileManager * mgr=[NSFileManager new];
    if([mgr fileExistsAtPath:toPath])
    {
        if([mgr fileExistsAtPath:tmpPath])
        {
            [mgr removeItemAtPath:tmpPath error:&error];
        }
       
        if(!error)
        {
            [mgr moveItemAtPath:toPath toPath:tmpPath error:nil];
        }

    }
}

#pragma mark - private method

+ (BOOL )createFolder:(NSString*) path {
    NSFileManager *filemgr = [NSFileManager new];
    
    NSError *error = nil;
    if (![filemgr fileExistsAtPath:path]) {
        [filemgr createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
    }
    
    // ensure all cache directories are there
    if(error)
    {
        NSLog(@"Failed to create cache directory");
        return NO;
    }
    return  YES;
}


+(NSString*) downloadPathWithURL:(NSURL*) url type:(PathType) type
{
    NSString *fileName=[url lastPathComponent];
    NSString *directoryName=@"Download";
    NSString * rootFolder=[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject];
    rootFolder=[rootFolder stringByAppendingPathComponent:directoryName];
    NSString * dirPath = nil;
    if(type==kPTFinnal)
    {
        dirPath=[rootFolder stringByAppendingString:@"/Final"];
    }
    else
    {
        dirPath=[rootFolder stringByAppendingString:@"/Tmp"];
    }
    [self createFolder:dirPath];
    
    NSString * fullPath=[dirPath stringByAppendingPathComponent:fileName];
    
    return  fullPath;
}


+ (unsigned long long)fileSizeForPath:(NSString *)path {
    signed long long fileSize = 0;
    NSFileManager *fileManager = [NSFileManager new];
    if ([fileManager fileExistsAtPath:path]) {
        NSError *error = nil;
        NSDictionary *fileDict = [fileManager attributesOfItemAtPath:path error:&error];
        if (!error && fileDict) {
            fileSize = [fileDict fileSize];
        }
    }
    return fileSize;
}





@end
