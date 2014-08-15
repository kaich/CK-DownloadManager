//
//  CKDownloadHTTPConnection.h
//  aisiweb
//
//  Created by Mac on 14-6-20.
//  Copyright (c) 2014年 weiaipu. All rights reserved.
//

#import "HTTPConnection.h"

@interface CKDownloadHTTPConnection : HTTPConnection
@property(nonatomic,strong) NSMutableDictionary * bodyDataDictionary;
@end
