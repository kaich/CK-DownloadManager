//
//  CKRefrenceRequestManager.h
//  aisiweb
//
//  Created by Mac on 14-6-20.
//  Copyright (c) 2014年 weiaipu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKDownloadFileModel+Json.h"

typedef void(^DownloadCompleteBlock)(id result);
typedef void(^DownloadFailed)(id error);

@interface CKRefrenceRequestManager : NSObject
@property(nonatomic,copy) DownloadCompleteBlock completeBlock;
@property(nonatomic,copy) DownloadFailed  failedBlock;

-(void) getRefrenceDownloadByAddress:(NSString *)address  deviceNameIdentifier:(NSString*) name;
@end
