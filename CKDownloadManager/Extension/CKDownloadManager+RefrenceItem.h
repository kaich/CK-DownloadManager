//
//  CKDownloadManager+RefrenceItem.h
//  aisiweb
//
//  Created by Mac on 14-6-20.
//  Copyright (c) 2014年 weiaipu. All rights reserved.
//

#import "CKDownloadManager.h"

 typedef void(^InsertRefrenceModelBlock)(id<CKDownloadModelProtocal> model);

@interface CKDownloadManager (RefrenceItem)
@property(nonatomic,copy) InsertRefrenceModelBlock insertRefrenceBlock;


-(void)insertRefrenceModel:(id<CKDownloadModelProtocal>)model;
@end
