//
//  CKDownloadFilter.h
//  aisiweb
//
//  Created by mac on 15/2/10.
//  Copyright (c) 2015年 weiaipu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKDownloadModelProtocal.h"

typedef BOOL(^CKFilterConditionBlock)(id<CKDownloadModelProtocal> model);

@interface CKDownloadFilter : NSObject

/**
 *  过滤条件（NSPredicate) filter works on [downloadEntities] [downloadCompleteEntities], the model property name as the key  and  value as the value.
 */
@property(nonatomic,strong) id filterParams;
/**
 *  过滤条件block
 */
@property(nonatomic,copy) CKFilterConditionBlock filterConditionBlock;


/**
 *  过滤集合
 *
 *  @param theArray 被过滤的
 *
 *  @return 过滤成功的集合
 */
-(NSMutableArray *) filteArray:(NSArray*) theArray;

/**
 *  判断是否能被过滤
 *
 *  @param theObject 被过滤的
 *
 *  @return YES 过滤成功  NO 过滤失败
 */
-(BOOL) filtePassed:(id<CKDownloadModelProtocal>) theObject;
@end
