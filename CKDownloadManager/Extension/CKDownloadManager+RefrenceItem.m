//
//  CKDownloadManager+RefrenceItem.m
//  aisiweb
//
//  Created by Mac on 14-6-20.
//  Copyright (c) 2014年 weiaipu. All rights reserved.
//

#import "CKDownloadManager+RefrenceItem.h"
#import "LKDBHelper.h"

static NSString * InsertRefrenceBlock=nil;

@implementation CKDownloadManager (RefrenceItem)
@dynamic insertRefrenceBlock;

-(void)insertRefrenceModel:(id<CKDownloadModelProtocal>)model
{
    [[LKDBHelper getUsingLKDBHelper] insertWhenNotExists:model];
    
    if(self.filterParams)
    {
        [_filterDownloadCompleteEntities addObject:model];
        
    }

    [_downloadCompleteEntityOrdinalDic setObject:model forKey:URL(model.URLString)];
    
    if(self.insertRefrenceBlock)
        self.insertRefrenceBlock(model);
    
}


#pragma mark - dynamic
-(void) setInsertRefrenceBlock:(InsertRefrenceModelBlock)insertRefrenceBlock
{
    objc_setAssociatedObject(self, &InsertRefrenceBlock, insertRefrenceBlock, OBJC_ASSOCIATION_COPY);
}

-(InsertRefrenceModelBlock) insertRefrenceBlock
{
   return  objc_getAssociatedObject(self, &InsertRefrenceBlock);
}

@end
