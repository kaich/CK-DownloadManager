//
//  MainXmlOperation.m
//  i4Connect
//
//  Created by Alan on 13-12-6.
//  Copyright (c) 2013年 weiaipu. All rights reserved.
//

#import "MainXmlOperation.h"
#import "GDataXMLNode.h"

static NSString * ADXMLPath = @"i4/adlist/adinfo";
static NSString * appXMLPath = @"i4/applist/app";

@interface MainXmlOperation()
@property (nonatomic, strong)NSData *XMLData;
@end

@implementation MainXmlOperation
- (id)initWithData:(NSData *)data{
    self = [super init];
    if (self) {
        _appRecordList = [[NSMutableArray alloc] initWithCapacity:0];
        _XMLData = [[NSData alloc] initWithData:data];
    }
    return self;
}

-(void)main{
    NSError *appError = nil;
    
    //App List
    
    GDataXMLDocument *appDoc = [[GDataXMLDocument alloc] initWithData:_XMLData options:0 error:nil];
    NSArray *arr1 = [appDoc nodesForXPath:appXMLPath error:&appError];
    for (GDataXMLElement *subElement in arr1) {
        AppListRecord *appRecord = [[AppListRecord alloc] init];
        appRecord.appId  =  [[[[subElement elementsForName:@"id"] lastObject] stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        appRecord.appName =  [[[[subElement elementsForName:@"appname"] lastObject] stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        appRecord.sLogan =  [[[[subElement elementsForName:@"slogan"] lastObject] stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        appRecord.sLoganColor = [[[[subElement elementsForName:@"slogancolor"] lastObject] stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        appRecord.icon  =  [[[[subElement elementsForName:@"icon"] lastObject] stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        appRecord.version  =  [[[[subElement elementsForName:@"version"] lastObject] stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        appRecord.size  =  [[[[subElement elementsForName:@"size"] lastObject] stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        appRecord.path  =  [[[[subElement elementsForName:@"path"] lastObject] stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        appRecord.itemId  =  [[[[subElement elementsForName:@"itemid"] lastObject] stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        appRecord.sourceid  =  [[[[subElement elementsForName:@"sourceid"] lastObject] stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        appRecord.downLoaded = [[[[subElement elementsForName:@"downloaded"] lastObject] stringValue]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        appRecord.plist = [[[[subElement elementsForName:@"plist"] lastObject] stringValue]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        appRecord.pkageType = [[[[subElement elementsForName:@"pkagetype"] lastObject] stringValue] intValue];
        
        appRecord.buyuseid = [[[subElement elementsForName:@"buyuseid"] lastObject] stringValue];
        
        appRecord.appprice = [[[subElement elementsForName:@"appprice"] lastObject] stringValue];
        
        appRecord.sizebyte = [[[[subElement elementsForName:@"sizebyte"] lastObject] stringValue] intValue];
        appRecord.minversion = [[[subElement elementsForName:@"minversion"] lastObject] stringValue];
        appRecord.isfull = [[[subElement elementsForName:@"isfull"] lastObject] stringValue];
        [self.appRecordList addObject:appRecord];
    }
}
@end
