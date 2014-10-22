//
//  CKSingletonHTTPServer.m
//  aisiweb
//
//  Created by Mac on 14-6-23.
//  Copyright (c) 2014年 weiaipu. All rights reserved.
//

#import "CKSingletonHTTPServer.h"

#ifdef CKNEARBY
#import "CKDownloadHTTPConnection.h"
#endif


#define DOWNLOADPLISTFILE [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,NSUserDomainMask,YES)objectAtIndex:0] stringByAppendingPathComponent:@"Download"]


@implementation CKSingletonHTTPServer
@dynamic serviceNameIdentifier;

+ (instancetype)sharedInstance {
    static CKSingletonHTTPServer *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];;
    });
    
    return _sharedInstance;
}


-(void) go
{
    
    NSDictionary * txtDic=@{APP_KEY: self.serviceNameIdentifier};
    NSString * bonjourDomain=@"local.";
    
	[self setType:@"_http._tcp."];
	[self setPort:12345];
	NSString *webPath = DOWNLOADPLISTFILE ;
	[self setDocumentRoot:webPath];
    [self setDomain:bonjourDomain];
    [self setTXTRecordDictionary:txtDic];
#ifdef CKNEARBY
    [self setConnectionClass:[CKDownloadHTTPConnection class]];
#endif
    [self start:nil];
}




#pragma mark - dynamic method
-(NSString*) serviceNameIdentifier
{
    static NSString * UUIDString=nil;
    
    if(UUIDString==nil)
    {
        CFUUIDRef uuID=CFUUIDCreate(kCFAllocatorDefault);
        CFStringRef uuIDString=CFUUIDCreateString(kCFAllocatorDefault, uuID);
        UUIDString=(__bridge NSString*) uuIDString;
    }
    
    return UUIDString;
}


@end
