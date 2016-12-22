//
//  NSURLSessionDownloadTask+Download.m
//  Pods
//
//  Created by mac on 16/12/21.
//
//

#import "NSURLSessionTask+Download.h"

@implementation NSURLSessionTask (Download)

-(NSString *) downloadTmpFileName
{
    return [[[self valueForKey:@"downloadFile"] valueForKey:@"path"] lastPathComponent];
}


@end
