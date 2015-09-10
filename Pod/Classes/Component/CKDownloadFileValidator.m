//
//  CKDwonalodFileValidator.m
//  chengkai
//
//  Created by mac on 14/12/16.
//  Copyright (c) 2014年 chengkai. All rights reserved.
//

#import "CKDownloadFileValidator.h"
#import "CKDownloadPathManager.h"
#import "CKDownloadManager+MoveDownAndRetry.h"
#import "CKDownloadManager.h"
#import "CKFreeDiskManager.h"

#ifndef URL
#define URL(_STR_) [NSURL URLWithString:_STR_]
#endif



@interface CKDownloadManager ()
/**
 *  update model change to database
 *
 *  @param model downlaod task model
 */
-(void) updateDataBaseWithModel:(id<CKDownloadModelProtocal>) model;


@end


@interface CKDownloadFileValidator ()
@property(nonatomic,strong) CKFreeDiskManager * diskManager;
@end

@implementation CKDownloadFileValidator

-(instancetype) init
{
    self = [super init];
    if(self)
    {
        self.isValidateFileSize = YES;
        self.isValidateFileContent = YES;
        self.isValidateFreeSpace = YES;
        self.diskManager = [[CKFreeDiskManager alloc] init];
        self.diskManager.mininumFreeSpaceBytes= 300*1024*1024;
    }
    return self;
}

-(void) validateFileSizeWithModel:(id<CKValidatorModelProtocal,CKDownloadModelProtocal>) model completeBlock:(DownloadFileValidateCompleteBlock) completeBlock
{

    if(model)
    {
        
        if(!self.isValidateFileSize)
        {
            if(completeBlock)
            {
                completeBlock(self,model,YES);
            }
            
            return ;
        }
        
        BOOL isSuccessful=YES;
        long long standardValue = model.standardFileSize;
        long long currentValue = [[CKDownloadPathManager sharedInstance] downloadContentSizeWithURL:URL(model.URLString)];
        if( currentValue != standardValue  &&  standardValue != 0)
        {
            model.downloadContentSize = 0;
            model.restTime = 0;
            model.speed = 0;
            [[CKDownloadPathManager sharedInstance] removeFileWithURL:URL(model.URLString)];
            [self.downloadManager pauseWithURL:URL(model.URLString)];
            model.downloadState= kDSDownloadErrorFinalLength;
            [self.downloadManager updateDataBaseWithModel:model];
            
            
            isSuccessful =NO;
        }
        
        if(completeBlock)
        {
            completeBlock(self,model,isSuccessful);
        }
    }
}


-(void) validateFileContentWithModel:(id<CKValidatorModelProtocal,CKDownloadModelProtocal>) model completeBlock:(DownloadFileValidateCompleteBlock) completeBlock
{
    if(model)
    {
        dispatch_async(dispatch_get_global_queue(0, 0), ^(void) {
            
            if(!self.isValidateFileContent)
            {
                if(completeBlock)
                {
                    completeBlock(self,model,YES);
                }
                
                return ;
            }
            
            
            __block BOOL isSuccessful=YES;
            if(model.standardFileValidationCode==nil || model.standardFileValidationCode.length == 0  || [model.standardFileValidationCode isEqualToString:@"0"])
            {
                isSuccessful=YES;
            }
            else
            {
                
                    NSTimeInterval  beforeValidateTime =[NSDate timeIntervalSinceReferenceDate];
                    
                    NSString * resultString =[self generateValidateCodeWithURL:URL(model.URLString)];
                    
                    NSTimeInterval  afterValiteTime =[NSDate timeIntervalSinceReferenceDate];
                    NSTimeInterval  interval = afterValiteTime -beforeValidateTime;
                    
                    
                    NSLog(@"%f",interval);
                    NSLog(@"%@",resultString);
                    
                    if(![resultString isEqualToString:[model.standardFileValidationCode uppercaseString]])
                    {
                        
                        model.downloadContentSize = 0;
                        model.restTime = 0;
                        model.speed = 0;
                        
                        [[CKDownloadPathManager sharedInstance] removeFileWithURL:URL(model.URLString)];
                        [self.downloadManager pauseWithURL:URL(model.URLString)];
                        model.downloadState = kDSDownloadErrorContent;
                        [self.downloadManager updateDataBaseWithModel:model];
                        
                        isSuccessful=NO;
                    }
                    else
                    {
                        isSuccessful=YES;
                    }
                
            }
            
            if(completeBlock)
            {
                completeBlock(self,model,isSuccessful);
            }
            
        });
    }

}


-(BOOL) validateEnougthFreeSpaceWithModel:(id<CKValidatorModelProtocal,CKDownloadModelProtocal>) model
{
    
    if(!self.isValidateFreeSpace)
    {
        return  YES;
    }
    
    self.diskManager.downloadManager = self.downloadManager;
    BOOL isOK = [self.diskManager isEnoughFreeSpaceWithModel:model];
    return isOK;
}

#pragma mark - private method
/**
 *  hex to hex string
 *
 *  @param bytes  bytes
 *  @param length bytes length
 *
 *  @return hex string
 */
-(NSString *) hexStringFromBytes:(Byte * ) bytes length:(NSUInteger) length
{
    NSString *hexStr=@"";
    for(int i=0;i<length;i++)
    {
        NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i]&0xff]; ///16进制数
        if([newHexStr length]==1)
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
        else
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
    }
    return  [hexStr uppercaseString];
}

/**
 *  generate validate code string
 *
 *  @param url download task url
 *
 *  @return validate code string
 */
-(NSString *) generateValidateCodeWithURL:(NSURL*) url
{
    NSString * finalPath=nil;
    NSString * tmpPath=nil;
    [[CKDownloadPathManager sharedInstance] SetURL:url toPath:&finalPath tempPath:&tmpPath];
    
    
    NSFileManager *fileManager = [NSFileManager new];
    
    
    NSString * resultString = @"";
    if ([fileManager fileExistsAtPath:finalPath])
    {
        
        NSUInteger readPointer = 0;
        const NSUInteger buffSize =  16384*16;
        Byte * buff =malloc(buffSize);
        NSUInteger  realChunkSize =0;
        Byte  currentByte=0;
        Byte  vBuff[8];
        
        NSUInteger i = 0;
        NSUInteger j = 0;
        memset(vBuff, 0x00, 8);
        
        long long fileLongsize =[[CKDownloadPathManager sharedInstance] downloadContentSizeWithURL:url];
        NSUInteger fileSize =[NSNumber numberWithLongLong:fileSize].integerValue;
        
        FILE *  file = fopen([finalPath cStringUsingEncoding:NSUTF8StringEncoding], "r");
        if(file)
        {
            while(readPointer < fileSize)
            {
                NSUInteger distanceToEndOfData = fileSize - readPointer;
                
                realChunkSize = (distanceToEndOfData > buffSize ? buffSize : distanceToEndOfData);
                
                fread(buff, 1, realChunkSize, file);
                
                
                for (j=0; j<64; j+=8){
                    currentByte=0;
                    for (i =j; i< realChunkSize ; i+=64) {
                        vBuff[j/(8)]= vBuff[j/(8)] ^ buff[i];
                    }
                    
                }
                
                readPointer += realChunkSize;
                
            }
            fclose(file);
        }
        
        resultString =[self hexStringFromBytes:vBuff length:8];
    }
    
   
    return resultString;
}


#pragma mark - dynamic method
-(void) setMininumFreeSpaceBytes:(long long)mininumFreeSpaceBytes
{
    self.diskManager.mininumFreeSpaceBytes=mininumFreeSpaceBytes;
}

-(long long) mininumFreeSpaceBytes
{
    return self.diskManager.mininumFreeSpaceBytes;
}

@end
