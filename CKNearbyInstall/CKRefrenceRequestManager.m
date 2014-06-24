//
//  CKRefrenceRequestManager.m
//  aisiweb
//
//  Created by Mac on 14-6-20.
//  Copyright (c) 2014年 weiaipu. All rights reserved.
//

#import "CKRefrenceRequestManager.h"
#import "ASIFormDataRequest.h"

@implementation CKRefrenceRequestManager
-(void) getRefrenceDownloadByAddress:(NSString *)address  deviceNameIdentifier:(NSString*) name
{

    NSString * urlString=[NSString stringWithFormat:@"http://%@:12345/downloadApps",address];
    NSURL * url=[NSURL URLWithString:urlString];
    ASIFormDataRequest  * request =[[ASIFormDataRequest alloc] initWithURL:url];
    request.requestMethod=@"POST";
    
    __weak typeof(request)weakRequest = request;

    [request setCompletionBlock:^(void){
        NSMutableArray * results=[NSMutableArray array];
        
        NSData * jsonData=weakRequest.responseData;
        NSDictionary * jsonDic=[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil];
        
        NSString * code =[jsonDic objectForKey:@"resultCode"];
        
        if([code intValue]==1)
        {
            NSMutableArray * jsonAry=[jsonDic objectForKey:@"body"];
            for (NSDictionary * emDic in jsonAry) {
                CKDownloadFileModel * model=[[CKDownloadFileModel alloc] init];
                [model modelFromJson:emDic];
                
                [results addObject:model];
            }
                
            
            if(self.completeBlock)
                self.completeBlock(results);
        }
        else if([code intValue]==0)
        {
            NSString * result=[jsonDic objectForKey:@"result"];
            if(self.failedBlock)
                self.failedBlock(result);
        }
    }];
    
    [request setFailedBlock:^{
       if(self.failedBlock)
           self.failedBlock(weakRequest.error);
    }];
    
    [request setPostValue:name forKey:@"deviceName"];
    
    [request startAsynchronous];
}
@end
