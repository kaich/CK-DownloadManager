//
//  CKFreeDiskManager.m
//  chengkai
//
//  Created by mac on 15/1/8.
//  Copyright (c) 2015年 chengkai. All rights reserved.
//

#import "CKFreeDiskManager.h"
#import "CKDownloadPathManager.h"
#import "CKValidatorModelProtocal.h"

@interface CKDownloadManager ()
/**
 *  all downloading task
 *
 *  @return
 */
-(NSArray *) allDowndingTask;

@end

@implementation CKFreeDiskManager


-(BOOL) isEnoughFreeSpaceWithModel:(id<CKValidatorModelProtocal>)model
{
    long long freeDisk = [CommonHelper getFreeDiskspace];
    long long  downloadTotalSize = 0;
    long long downloadAppSize =0;
    NSArray * downloadingArray = [self.downloadManager allDowndingTask];
    for (id<CKDownloadModelProtocal,CKValidatorModelProtocal> model  in downloadingArray) {
        downloadTotalSize+=model.standardFileSize;
        downloadAppSize=downloadAppSize + [CKDownloadPathManager downloadContentSizeWithURL:URL(model.URLString)];
    }
    
    
    if (freeDisk - model.standardFileSize - downloadTotalSize + downloadAppSize <= self.mininumFreeSpaceBytes)
    {
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [SVProgressHUD showErrorWithStatus:@"磁盘空间不足" duration:3];
        });
        
        return  NO;
    }
    else
    {
        return  YES;
    }
}


+(uint64_t)getFreeDiskspace {
    uint64_t totalSpace = 0.0f;
    uint64_t totalFreeSpace = 0.0f;
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
    
    if (dictionary) {
        NSNumber *fileSystemSizeInBytes = [dictionary objectForKey: NSFileSystemSize];
        NSNumber *freeFileSystemSizeInBytes = [dictionary objectForKey:NSFileSystemFreeSize];
        totalSpace = [fileSystemSizeInBytes floatValue];
        totalFreeSpace = [freeFileSystemSizeInBytes floatValue];
        NSLog(@"Memory Capacity of %llu MiB with %llu MiB Free memory available.", ((totalSpace/1024ll)/1024ll), ((totalFreeSpace/1024ll)/1024ll));
    } else {
        NSLog(@"Error Obtaining System Memory Info: Domain = %@, Code = %ld", [error domain], (long)[error code]);
    }
    
    return totalFreeSpace;
}

@end
