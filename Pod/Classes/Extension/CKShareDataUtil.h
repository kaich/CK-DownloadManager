//
//  ShareDataUtil.h
//  chengkai
//
//  Created by mac on 14/10/28.
//  Copyright (c) 2014年 chengkai. All rights reserved.
//
//  This file for today extension.you can create it in framework or static libary to share code. you must contain AutoCoding file also. 

#import <Foundation/Foundation.h>

typedef void(^SharedDataChangedBlok)(NSArray * tasks);

@interface CKShareDataUtil : NSObject

@property(nonatomic,assign) BOOL isChanged;
@property(nonatomic,copy) SharedDataChangedBlok  dataChangedBlock;

/**
 *  singleton method
 *
 *  @return instance
 */
+(CKShareDataUtil *) sharedInstance;

/**
 *  set group identifier
 *
 *  @param groupIdentifier
 */
-(void) setGroupIdentifier:(NSString *)groupIdentifier;

/**
 *  check status , in extension you must call it in viewdidload or init
 */
-(void) checkContainerStatus;

/**
 *  set download entity for url
 *
 *  @param entity download entity
 *  @param url    url
 */
-(void) setEntity:(id) entity URL:(NSURL *) url;

/**
 *  set downloading task status
 *
 *  @param isHasDownloading yes has downloading no all paused
 */
-(void) setHasDownloading:(BOOL) isHasDownloading;

/**
 *  containt set heart beat, block call back
 */
-(void) setheartBeat;

/**
 *  get download entity for url
 *
 *  @param url your url
 */
-(id) getEntityByURL:(NSURL *) url;

/**
 *  get all entities
 *
 *  @return all entities
 */
-(NSArray*) entities;

/**
 *  get all urls
 *
 *  @return all urls
 */
-(NSArray *) urlsArray;

@end
