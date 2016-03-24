//
//  CKDownloadBaseModel.m
//  DownloadManager
//
//  Created by Mac on 14-5-21.
//  Copyright (c) 2014年 Mac. All rights reserved.
//



#import "CKDownloadBaseModel.h"


@implementation CKDownloadBaseModel
@dynamic dependencies;

-(id) init
{
    
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.restTime=0;
    
    return self;

}


#pragma mark -  DB Mehtod


+(NSString *)getTableName
{
    return @"tb_downlod";
}

+(NSString *)getPrimaryKey
{
    return URL_LINK_STRING;
}



+(NSDictionary *)getTableMapping
{
    NSMutableDictionary * dic=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"title",DWONLOAD_ITME_NAME,@"URLString",URL_LINK_STRING,@"downloadFinalPath",FINAL_PATH_STRING,@"totalCotentSize",TOTAL_CONTENT_SIZE,@"downloadState",DOWNLOAD_STATE,@"downloadContentSize",DOWNLOAD_CONTENT_SIZE,@"imgURLString",ICON_IMAGE_URL,@"restTime",DOWNLOAD_REST_TIME,@"dependenciesString",DOWNLOAD_DEPENDENCY,@"extraDownloadData",EXTRA_DOWNLOAD_DATA,nil];
    NSDictionary * additionPropertiesMapping=[self additionTableColumnMapping];
    if(additionPropertiesMapping.count>0)
    {
        [dic addEntriesFromDictionary:additionPropertiesMapping];
    }
    return dic;
}


+(NSInteger)getTableVersion
{
    return 1;
}

+(NSDictionary*) additionTableColumnMapping
{
    return  nil;
}



#pragma mark -  dynamic method
-(void) setDependencies:(NSArray *)dependencies
{
    self.dependenciesString=[dependencies componentsJoinedByString:@","];
    _dependencies=dependencies;
}


-(NSArray*) dependencies
{
    if([self.dependenciesString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length ==0)
        return  nil;
    
    NSArray * dependencyArray=[self.dependenciesString componentsSeparatedByString:@","];
    NSMutableArray * results=[NSMutableArray array];
    for (NSString * emDependency  in dependencyArray) {
        [results addObject:[NSURL URLWithString:emDependency]];
    }
    _dependencies=[results copy];
    return _dependencies;
}

@end
