//
//  CKOrdinalDictionary.h
//  aisiweb
//
//  Created by mac on 15/1/12.
//  Copyright (c) 2015年 weiaipu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CKMutableOrdinalDictionary : NSObject

@property (readonly, copy) NSArray * array;

@property (readonly, copy) NSDictionary * dictionary;

@property(nonatomic,readonly) NSUInteger count;

/**
 *  set object for key. if new object, it's added at end. else keep  original index
 *
 *  @param anObject
 *  @param aKey
 */
-(void) setObject:(id) anObject forKey:(id<NSCopying>) aKey;

/**
 *   set object for key. it's replace at the index
 *
 *  @param anObject
 *  @param aKey
 *  @param anIndex  index of the object
 */
-(void) setObject:(id) anObject forKey:(id<NSCopying>) aKey index:(NSUInteger) anIndex;

/**
 *  remove object for key
 *
 *  @param aKey
 */
- (void)removeObjectForKey:(id)aKey;

/**
 *  remove object at index
 *
 *  @param index
 */
- (void)removeObjectAtIndex:(NSUInteger)index;


/**
 *  remove object
 *
 *  @param anObject
 */
- (void)removeObject:(id)anObject;

/**
 *  object for key
 *
 *  @param aKey
 *
 *  @return 
 */
- (id)objectForKey:(id)aKey;

/**
 *  index of object
 *
 *  @param anObject
 *
 *  @return index
 */
- (NSUInteger)indexOfObject:(id)anObject;

@end
