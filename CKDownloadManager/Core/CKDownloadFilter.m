//
//  CKDownloadFilter.m
//  aisiweb
//
//  Created by mac on 15/2/10.
//  Copyright (c) 2015年 weiaipu. All rights reserved.
//

#import "CKDownloadFilter.h"

@implementation CKDownloadFilter

-(NSMutableArray *) filteArray:(NSArray*) theArray
{
    NSMutableArray * filtedEntities =nil;
    if(self.filterParams)
    {
        NSPredicate * predicate=[self createConditinWithCondition:self.filterParams,nil];
        filtedEntities= [[theArray filteredArrayUsingPredicate:predicate] mutableCopy];
    }
    else if(self.filterConditionBlock)
    {
        filtedEntities =[NSMutableArray array];
        for (id<CKDownloadModelProtocal> emModel in theArray) {
            if(self.filterConditionBlock(emModel))
            {
                [filtedEntities addObject:emModel];
            }
        }
    }
    else
    {
        NSAssert(1, @"either filterParams or filterConditionBlock must not be nil");
    }
    
    return filtedEntities;
}


-(BOOL) filtePassed:(id<CKDownloadModelProtocal>) theObject
{
    BOOL passed = NO;
    if(self.filterParams)
    {
        NSPredicate * predicate=[self createConditinWithCondition:self.filterParams,nil];
        passed= [predicate evaluateWithObject:theObject];
    }
    else if(self.filterConditionBlock)
    {
        passed= self.filterConditionBlock(theObject);
    }
    else
    {
        NSAssert(1, @"either filterParams or filterConditionBlock must not be nil");
    }
                 
    return  passed;
}



-(NSPredicate * ) createConditinWithCondition:(NSString *) condition, ...
{
    NSMutableString * finalCondition=[NSMutableString stringWithFormat:@"%@",condition];
    
    va_list args;
    va_start(args, condition);
    
    if(condition)
    {
        id params;
        while ((params=va_arg(args, id))) {
            if([condition isKindOfClass:[NSDictionary class]])
            {
                [finalCondition appendString:[self createConditionWithParams:(NSDictionary*)condition]];
            }
            else if([condition isKindOfClass:[NSString class]])
            {
                [finalCondition appendFormat:@"AND %@",params];
            }
        }
    }
    
    va_end(args);
    
    return [NSPredicate predicateWithFormat:finalCondition];
}


-(NSString *) createConditionWithParams:(NSDictionary*) params
{
    NSMutableString * result=[NSMutableString string];
    NSArray * allKeys=params.allKeys;
    for (NSString * emKey in allKeys) {
        NSString * value=[params objectForKey:emKey];
        [result appendFormat:@"AND %@ = %@ ",emKey,value];
    }
    
    return result;
}

@end
