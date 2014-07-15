//
//  UIView+ParabolaAnimate.h
//  aisiweb
//
//  Created by Mac on 14-7-11.
//  Copyright (c) 2014年 weiaipu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (ParabolaAnimate)

-(void) showAnimateWithWindowCoorditionPoint:(CGPoint ) targetPoint  needPlacehold:(BOOL) isNeed;

@end


@interface UIView (Snapshot)

- (UIImage *)snapshot;

@end