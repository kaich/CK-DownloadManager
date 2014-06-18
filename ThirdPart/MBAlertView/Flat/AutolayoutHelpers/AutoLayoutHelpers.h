//
//  AutoLayoutHelpers.h
//
//  Created by Mo Bitar on 5/8/13.
//

#import "UIView+Autolayout.h"
#import <Foundation/Foundation.h>

NSLayoutConstraint *constraintAttributeWithPriority(UIView *item1, UIView *item2, NSLayoutAttribute attribute,
                                                    CGFloat offset, UILayoutPriority priority);

NSLayoutConstraint *constraintEqual(UIView *item1, UIView *item2, NSLayoutAttribute attribute, CGFloat offset);
NSLayoutConstraint *constraintEqualAttributes(UIView *item1, UIView *item2, NSLayoutAttribute attribute1, NSLayoutAttribute attribute2, CGFloat offset);
NSLayoutConstraint *constraintEqualWithMultiplier(UIView *item1, UIView *item2, NSLayoutAttribute attribute, CGFloat offset, CGFloat multiplier);

NSLayoutConstraint *constraintEqualAttributesWithMultiplier(UIView *item1, UIView *item2, NSLayoutAttribute attribute1,
                                                            NSLayoutAttribute attribute2, CGFloat offset, CGFloat multiplier);

NSLayoutConstraint *constraintCenterX(UIView *item1, UIView *item2);
NSLayoutConstraint *constraintCenterXWithOffset(UIView *item1, UIView *item2, CGFloat offset);

NSLayoutConstraint *constraintCenterY(UIView *item1, UIView *item2);
NSLayoutConstraint *constraintCenterYWithOffset(UIView *item1, UIView *item2, CGFloat offset);

NSLayoutConstraint *constraintTrailVertically(UIView *item1, UIView *item2, CGFloat offset);
NSLayoutConstraint *constraintTrailHorizontally(UIView *item1, UIView *item2, CGFloat offset);

NSLayoutConstraint *constraintLeadVertically(UIView *item1, UIView *item2, CGFloat offset);
NSLayoutConstraint *constraintLeadHorizontally(UIView *item1, UIView *item2, CGFloat offset);

NSLayoutConstraint *constraintWidth(UIView *item1, UIView *item2, CGFloat offset);
NSLayoutConstraint *constraintHeight(UIView *item1, UIView *item2, CGFloat offset);

NSLayoutConstraint *constraintTop(UIView *item1, UIView *item2, CGFloat offset);
NSLayoutConstraint *constraintBottom(UIView *item1, UIView *item2, CGFloat offset);
NSLayoutConstraint *constraintLeft(UIView *item1, UIView *item2, CGFloat offset);
NSLayoutConstraint *constraintRight(UIView *item1, UIView *item2, CGFloat offset);

NSLayoutConstraint *constraintAbsolute(UIView *item1, NSLayoutAttribute attribute, CGFloat offset);

NSArray *constraintsAbsoluteSize(UIView *item, CGFloat width, CGFloat height);
NSArray *constraintsCenter(UIView *item, UIView *centerTo);
NSArray *constraintsCenterWithOffset(UIView *item, UIView *centerTo, CGFloat xOffset, CGFloat yOffset);
NSArray *constraintsEqualSize(UIView *item1, UIView *item2, CGFloat widthOffset, CGFloat heightOffset);
NSArray *constraintsEqualPosition(UIView *item1, UIView *item2, CGFloat xOffset, CGFloat yOffset);
NSArray *constraintsEqualSizeAndPosition(UIView *item1, UIView *item2);
NSArray *constraintsHeightNotGreaterThanConstant(UIView *item1, UIView *item2, CGFloat constant);
NSArray *constraintsHeightGreaterThanOrEqual(UIView *item1, UIView *item2);