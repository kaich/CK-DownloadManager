//
//  CKDownloadSpeedAverageQueue.h
//  chengkai
//
//  Created by Mac on 14-7-9.
//  Copyright (c) 2014年 chengkai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CKDownloadSpeedAverageQueue : NSObject
@property(nonatomic,readonly) CGFloat speed;
@property(nonatomic,assign) NSInteger intervalLength;


-(CKDownloadSpeedAverageQueue *) pushCurrentDownloadSize:(long long) value;
-(CKDownloadSpeedAverageQueue *) pushCurrentDownloadTime:(NSTimeInterval) value;

-(void) reset;
@end
