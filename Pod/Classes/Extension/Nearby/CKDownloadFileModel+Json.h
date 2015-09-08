//
//  CKDownloadFileModel+Json.h
//  chengkai
//
//  Created by Mac on 14-6-20.
//  Copyright (c) 2014年 chengkai. All rights reserved.
//

#import "CKDownloadFileModel.h"

@interface CKDownloadFileModel (Json)
-(NSDictionary*) jsonDictionary;
-(void) modelFromJson:(id) josnObject;
@end
