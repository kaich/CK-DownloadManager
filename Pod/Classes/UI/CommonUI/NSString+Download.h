//
//  NSString+Download.h
//  Pods
//
//  Created by mac on 16/12/15.
//
//

#import <Foundation/Foundation.h>

@interface NSString (Download)

/**
 大于1M，则转化成M单位的字符串; 不到1M,但是超过了1KB，则转化成KB单位; 剩下的都是小于1K的，则转化成B单位
 */
+ (NSString *)ck_fileSize:(long long)asize;

@end
