//
//  UIView+Animations.m
//  TwoTask
//
//  Created by Mo Bitar on 12/21/12.
//  Copyright (c) 2012 progenius, inc. All rights reserved.
//

#import "UIView+Alert.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIView (Alert)

/* centers the views in the array with respect to self and given offset */
/* views is an array of dictionarys with keys "view" and "offset" */
- (void)centerViewsVerticallyWithin:(NSArray*)views {
    /* calculate y origin of first view */
    float heightOfAllViews = 0;
    
    for(NSDictionary *dic in views) {
        UIView *view = [dic objectForKey:@"view"];
        CGFloat offset = [[dic objectForKey:@"offset"] floatValue];
        heightOfAllViews += view.bounds.size.height + offset;
    }
    
    CGFloat selfHeight = self.bounds.size.height;
    CGFloat yOriginOfFirstView = selfHeight/2.0 - heightOfAllViews/2.0;
    CGFloat currentYOrigin = yOriginOfFirstView;
    
    for(NSDictionary *dic in views) {
        UIView *view = [dic objectForKey:@"view"];
        CGFloat offset = [[dic objectForKey:@"offset"] floatValue];
        CGRect rect = view.frame;
        rect.origin = CGPointMake(rect.origin.x, currentYOrigin + offset);
        view.frame = rect;
        currentYOrigin += rect.size.height + offset;
    }
}

// wrapper
- (void)resignFirstRespondersForSubviews {
    [self resignFirstRespondersForView:self];
}

// helper
- (void)resignFirstRespondersForView:(UIView*)view {
    for (UIView *subview in [view subviews]) {
        if ([subview isKindOfClass:[UITextField class]] || [subview isKindOfClass:[UITextView class]]) {
            [(id)subview resignFirstResponder];
        }
        [self resignFirstRespondersForView:subview];
    }
}

@end
