//
//  CKOrdinalDictionary.m
//  aisiweb
//
//  Created by mac on 15/1/12.
//  Copyright (c) 2015年 weiaipu. All rights reserved.
//

#import "CKMutableOrdinalDictionary.h"

@interface CKMutableOrdinalDictionary ()
/**
 *  internal array. make sure the index
 */
@property(nonatomic,strong) NSMutableArray * internalArray;
/**
 *  internal dictionary. easy to find object
 */
@property(nonatomic,strong) NSMutableDictionary * internalDictionary;
@end

@implementation CKMutableOrdinalDictionary

-(instancetype) init
{
    self = [super init];
    if(self)
    {
        self.internalArray = [NSMutableArray array];
        self.internalDictionary = [NSMutableDictionary dictionary];
    }
    
    return self;
}

-(void) setObject:(id) anObject forKey:(id<NSCopying>) aKey
{
    if([self.internalDictionary objectForKey:aKey])
    {
        NSUInteger index = [self.internalArray indexOfObject:aKey];
        [self.internalArray replaceObjectAtIndex:index withObject:anObject];
    }
    else
    {
        [self.internalArray addObject:anObject];
    }
    
    [self.internalDictionary setObject:anObject forKey:aKey];
}


-(void) setObject:(id) anObject forKey:(id<NSCopying>) aKey index:(NSUInteger) anIndex;
{
    if([self.internalDictionary objectForKey:aKey])
    {
        if(anIndex < self.internalArray.count)
        {
            [self.internalArray replaceObjectAtIndex:anIndex withObject:anObject];
        }
        else
        {
            NSAssert(YES, @"index larger than count of elements");
        }
    }
    else
    {
        [self.internalArray addObject:aKey];
    }
    
    [self.internalDictionary setObject:anObject forKey:aKey];
}

- (void)removeObjectForKey:(id)aKey
{
    id anObject = [self.internalDictionary objectForKey:aKey];
    if(anObject)
    {
        [self.internalArray removeObject:anObject];
        [self.internalDictionary removeObjectForKey:aKey];
    }
}

- (void)removeObjectAtIndex:(NSUInteger)index
{
    if(self.internalArray.count > index)
    {
        id anObject = [self.internalArray objectAtIndex:index];
        [self removeObjectForKey:anObject];
    }
}

- (void)removeObject:(id)anObject
{
    NSArray * allKeys = [self.internalDictionary allKeysForObject:anObject];
    if(allKeys.count >0)
    {
        [self.internalArray removeObject:anObject];
        for (id emKey in allKeys) {
            [self.internalDictionary removeObjectForKey:emKey];
        }
        
    }
}


- (id)objectForKey:(id)aKey
{
    return  [self.internalDictionary objectForKey:aKey];
}

- (NSUInteger)indexOfObject:(id)anObject
{
    return [self.internalArray indexOfObject:anObject];
}


#pragma mark - dynamic method
-(NSUInteger) count
{
    return self.internalArray.count;
}

-(NSArray *) array
{
    return [self.internalArray copy];
}

-(NSDictionary *) dictionary
{
    return [self.internalDictionary copy];
}

@end
