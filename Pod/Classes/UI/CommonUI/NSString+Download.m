//
//  NSString+Download.m
//  Pods
//
//  Created by mac on 16/12/15.
//
//

#import "NSString+Download.h"

@implementation NSString (Download)

+ (NSString *)ck_fileSize:(long long)asize
{
    CGFloat size = asize / 1024.0;
    if(size >= 1000)
    {
        return [NSString stringWithFormat:@"%0.2fMB",size/1024];
        
    }
    else if(size>=0&&size<1000)
    {
        return [NSString stringWithFormat:@"%.fKB",size];
    }
    else
    {
        return @"1KB";
    }
    
}

@end
