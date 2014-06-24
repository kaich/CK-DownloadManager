//
//  CKDownloadHTTPConnection.m
//  aisiweb
//
//  Created by Mac on 14-6-20.
//  Copyright (c) 2014年 weiaipu. All rights reserved.
//

#import "CKDownloadHTTPConnection.h"
#import "HTTPFileResponse.h"
#import "CKDownloadManager.h"
#import "LKDBHelper.h"
#import "CKDownloadFileModel.h"
#import "CKDownloadFileModel+Json.h"
#import "HTTPDataResponse.h"
#import "MBFlatAlertView.h"
#import "CKNearbyMacro.h"


#define HTTP_RESPONSE_HEADER_CODE @"resultCode"
#define HTTP_RESPONSE_HEADER_RESULT @"result"
#define HTTP_RESPONSE_HEADER_BODY @"body"

@interface CKDownloadHTTPConnection()
{
    __block  int clickButtonState;
}
@end

@implementation CKDownloadHTTPConnection


-(BOOL) supportsMethod:(NSString *)method atPath:(NSString *)path
{
    BOOL result= [super supportsMethod:method atPath:path];
    
    if([path hasPrefix:@"/downloadApps"])
    {
        return  YES;
    }
    else
    {
        return  result;
    }

}


- (void)processBodyData:(NSData *)postDataChunk
{
    NSString * resultStr=[[NSString alloc] initWithData:postDataChunk encoding:NSUTF8StringEncoding];
    
    NSArray * items=[resultStr componentsSeparatedByString:@"&"];
    
    self.bodyDataDictionary=[NSMutableDictionary dictionary];
    for (NSString * emItem in items) {
        NSRange range=[emItem rangeOfString:@"="];
        NSString * paramKey=[emItem substringToIndex:range.location];
        NSString * paramValueData=[emItem substringFromIndex:range.location+1];
        NSString * paramValue=[self convertChinese:paramValueData];
        
        [self.bodyDataDictionary setObject:paramValue forKey:paramKey];
    }
 
}

- (NSObject<HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:(NSString *)path;
{
	
	NSString *filePath = [self filePathForURI:path allowDirectory:NO];
    
    BOOL isDir = NO;
	
	if (filePath && [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDir] && !isDir)
	{
		return [[HTTPFileResponse alloc] initWithFilePath:filePath forConnection:self];
        
	}
    else if([path hasPrefix:@"/downloadApps"])
    {

        
        NSDictionary * parmas=[self bodyDataDictionary];
        NSString * deviceName=[parmas objectForKey:@"deviceName"];
        NSString * msg=[NSString stringWithFormat:@"您是否要与%@共享您的已下载",deviceName];
        BOOL isSure=[self showModalAlertView:msg];
      
        
        if(isSure)
        {
            NSMutableArray * jsonResult=[NSMutableArray array];
            NSArray * downloadCompleteAry= [CKDownloadManager sharedInstance].downloadCompleteEntities;
            for (CKDownloadFileModel * model in downloadCompleteAry) {
                NSDictionary * jsonModelDic=[model jsonDictionary];
                [jsonResult addObject:jsonModelDic];
            }
            
            NSDictionary  * finalDic=@{HTTP_RESPONSE_HEADER_RESULT: @"成功",
                                           HTTP_RESPONSE_HEADER_CODE : @"1",
                                             HTTP_RESPONSE_HEADER_BODY :jsonResult};
            
            NSData * jsonData=[NSJSONSerialization dataWithJSONObject:finalDic options:NSJSONWritingPrettyPrinted error:nil];
            
            return  [[HTTPDataResponse alloc] initWithData:jsonData];
        }
        else
        {
            NSString * msg=[NSString stringWithFormat:@"抱歉,%@拒绝与您共享",SELF_DEVICE_NAME_VALUE];
            NSDictionary * finalDic=@{HTTP_RESPONSE_HEADER_RESULT : msg,
                                 HTTP_RESPONSE_HEADER_CODE : @"0"};
            
             NSData * jsonData=[NSJSONSerialization dataWithJSONObject:finalDic options:NSJSONWritingPrettyPrinted error:nil];
            return  [[HTTPDataResponse alloc] initWithData:jsonData];
        }
    }
	
	return nil;
}


-(BOOL) showModalAlertView:(NSString*) msg
{
    clickButtonState=-1;
    

    dispatch_async(dispatch_get_main_queue(), ^(void) {
        MBFlatAlertView * alertView=[MBFlatAlertView alertWithTitle:@"温馨提示" detailText:msg  cancelTitle:@"取消" cancelBlock:^{
            clickButtonState=0;
        }];
        [alertView addButtonWithTitle:@"确定" type:MBFlatAlertButtonTypeNormal action:^{
            clickButtonState=1;
        }];
        
        [alertView addToDisplayQueue];
    });
    
    while (clickButtonState==-1) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate: [NSDate distantFuture]];
    }
    
    return clickButtonState==0 ? NO : YES;
}


-(NSString *) convertChinese:(NSString *) utf8String
{
    NSString * finalStr = [utf8String stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    return  finalStr;
}

@end
