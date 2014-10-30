//
//  ShareDataUtil.m
//  aisiweb
//
//  Created by mac on 14/10/28.
//  Copyright (c) 2014年 weiaipu. All rights reserved.
//

#import "CKShareDataUtil.h"


#define STRING_FROM_URL(_url_) _url_.absoluteString
#define URL_FROM_STRING(_str_) [NSURL URLWithString:_str_]

static NSInteger MaxHeartBeatInterval =10;

static NSString * DownloadTasksDicKey =@"tasks dictionary";
static NSString * DownloadURLArrayKey =@"url array";
static NSString * DownloadHasDownloadingKey =@"is has downloading key";
static NSString * DownloadContainerHeartBeat =@"container heart beat";
static CKShareDataUtil * Instance = nil;

@interface CKShareDataUtil ()
{
    NSString * _groupIdentifier;
}
@property(nonatomic,strong) NSTimer * timer;
@property(nonatomic,strong) NSUserDefaults * groupUserDefualt;
@end

@implementation CKShareDataUtil

-(instancetype) init
{
    self=[super init];
    if(self)
    {
        _groupIdentifier=nil;
        self.isChanged=NO;
        
    }
    
    return  self;
}

-(void) dealloc
{
    [self.timer invalidate];
    self.timer=nil;
}

+(CKShareDataUtil *) sharedInstance
{
    if(!Instance)
    {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            Instance= [[CKShareDataUtil alloc] init];
        });
    }
    
    return Instance ;
}


-(void) setGroupIdentifier:(NSString *)groupIdentifier
{
    self.groupUserDefualt=[[NSUserDefaults alloc] initWithSuiteName:groupIdentifier];
    _groupIdentifier=groupIdentifier;
}


-(void) checkContainerStatus
{
    if([self isHasDownloding])
    {
        [self startTimer];
    }
}

-(void) setEntity:(id) entity URL:(NSURL *) url
{
    [self checkValidate];

    [self addURL:url];
    [self addEnttiy:entity URL:url];
    
    self.isChanged=YES;
}


-(void) setHasDownloading:(BOOL) isHasDownloading
{
    [self checkValidate];
    
    [self.groupUserDefualt setBool:isHasDownloading forKey:DownloadHasDownloadingKey];
}


-(void) setheartBeat
{
    [self checkValidate];
    
    [self.groupUserDefualt setInteger:0 forKey:DownloadContainerHeartBeat];
}

-(id) getEntityByURL:(NSURL *) url
{
    [self checkValidate];
    
    id entity=[self entityFromURL:url];
    
    return entity;
}


-(NSArray*) entities
{
    NSArray * urls =[self urlsArray];
    NSMutableArray *  results=[NSMutableArray array];
    for (NSString * emURL in urls) {
        id entity =[self entityFromURL:URL_FROM_STRING(emURL)];
        [results addObject:entity];
        
    }
    
    return results;
}


-(NSArray *) urlsArray
{
    NSArray *  urls =[self.groupUserDefualt objectForKey:DownloadURLArrayKey];
    if(!urls)
        urls=[NSMutableArray array];
    return urls;
}

#pragma mark - private method
-(void) checkValidate
{
    if(_groupIdentifier ==nil)
    {
        @throw [NSException exceptionWithName:@"identfier error" reason:@"identfier can't be nil" userInfo:nil];
    }
}

-(NSDictionary * ) taskDictionary
{
    NSMutableDictionary * itemDic=[self.groupUserDefualt objectForKey:DownloadTasksDicKey];
    if(!itemDic)
        itemDic=[NSMutableDictionary dictionary];
    return itemDic;
}




-(void) addEnttiy:(id) entity URL:(NSURL *) url
{
    NSData * entityData=[self dataFromEntity:entity];
    NSMutableDictionary * itemDic=[[self taskDictionary] mutableCopy];
    [itemDic setObject:entityData forKey:STRING_FROM_URL(url)];
    [self.groupUserDefualt setObject:itemDic forKey:DownloadTasksDicKey];
    [self.groupUserDefualt synchronize];
}


-(id) entityFromURL:(NSURL *) url
{
    NSDictionary * tasksDic=[self taskDictionary];
    id entityData =[tasksDic objectForKey:STRING_FROM_URL(url)];
    id entity=[self entityFromData:entityData];
    return entity ;
}


-(void) addURL:(NSURL *) url
{
    NSMutableArray * urlAry=[[self urlsArray] mutableCopy];
    NSDictionary * tasksDic=[self taskDictionary];
    if(![tasksDic objectForKey:STRING_FROM_URL(url)])
    {
        [urlAry addObject:STRING_FROM_URL(url)];
        [self.groupUserDefualt setObject:urlAry forKey:DownloadURLArrayKey];
        [self.groupUserDefualt synchronize];
    }
    
}


-(NSData *) dataFromEntity:(id) entity
{
    NSData * data=[NSKeyedArchiver archivedDataWithRootObject:entity];
    return  data;
}

-(id) entityFromData:(NSData*) data
{
    id entity=[NSKeyedUnarchiver unarchiveObjectWithData:data];
    return entity;
}

-(BOOL) isHasDownloding
{
   return  [self.groupUserDefualt boolForKey:DownloadHasDownloadingKey];
}

-(NSInteger) heartBeat
{
    return [self.groupUserDefualt integerForKey:DownloadContainerHeartBeat];
}

-(void) increaseHeartBeat
{
    NSInteger  count = [self heartBeat] +1;
    [self.groupUserDefualt setInteger:count forKey:DownloadContainerHeartBeat];
}

-(BOOL) isDownloadContainerDeadOrStop
{
    if([self heartBeat] > MaxHeartBeatInterval || ![self isHasDownloding])
    {
        return YES;
    }
    
    return  NO;
}


-(void) startTimer
{
    self.timer=[NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(sharedDataChanged) userInfo:nil repeats:YES];
}


#pragma mark - Notification 
-(void) sharedDataChanged
{
    [self increaseHeartBeat];
    
    if([self isDownloadContainerDeadOrStop])
    {
        [self.timer invalidate];
        self.timer = nil;
    }
    
    if(self.groupUserDefualt)
    {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSArray * entitiesAry =[self entities];
            dispatch_async(dispatch_get_main_queue(), ^{
                if(self.dataChangedBlock)
                    self.dataChangedBlock(entitiesAry);
            });
        });
    }
    
    
}

@end
