//
//  AutoLayoutHelpers.m
//
//  Created by Mo Bitar on 5/8/13.
//

#import "AutoLayoutHelpers.h"

NSLayoutConstraint *constraintAttributeWithPriority(UIView *item1, UIView *item2, NSLayoutAttribute attribute,
                                                    CGFloat offset, UILayoutPriority priority)
{
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:item1 attribute:attribute relatedBy:NSLayoutRelationEqual toItem:item2 attribute:attribute multiplier:1.0 constant:offset];
    constraint.priority = priority;
    return constraint;
}

NSLayoutConstraint *constraintEqual(UIView *item1, UIView *item2, NSLayoutAttribute attribute, CGFloat offset)
{
    return [NSLayoutConstraint constraintWithItem:item1 attribute:attribute relatedBy:NSLayoutRelationEqual toItem:item2 attribute:attribute multiplier:1.0 constant:offset];
}

NSLayoutConstraint *constraintEqualAttributes(UIView *item1, UIView *item2, NSLayoutAttribute attribute1, NSLayoutAttribute attribute2, CGFloat offset)
{
    return [NSLayoutConstraint constraintWithItem:item1 attribute:attribute1 relatedBy:NSLayoutRelationEqual toItem:item2 attribute:attribute2 multiplier:1.0 constant:offset];
}

NSLayoutConstraint *constraintEqualWithMultiplier(UIView *item1, UIView *item2, NSLayoutAttribute attribute, CGFloat offset, CGFloat multiplier)
{
    return [NSLayoutConstraint constraintWithItem:item1 attribute:attribute relatedBy:NSLayoutRelationEqual toItem:item2 attribute:attribute multiplier:multiplier constant:offset];
}

NSLayoutConstraint *constraintEqualAttributesWithMultiplier(UIView *item1, UIView *item2, NSLayoutAttribute attribute1, NSLayoutAttribute attribute2, CGFloat offset, CGFloat multiplier)
{
    return [NSLayoutConstraint constraintWithItem:item1 attribute:attribute1 relatedBy:NSLayoutRelationEqual toItem:item2 attribute:attribute2 multiplier:multiplier constant:offset];
}

NSLayoutConstraint *constraintWidth(UIView *item1, UIView *item2, CGFloat offset)
{
     return [NSLayoutConstraint constraintWithItem:item1 attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:item2 attribute:NSLayoutAttributeWidth multiplier:1.0 constant:offset];
}

NSArray *constraintsCenter(UIView *item, UIView *centerTo)
{
    NSLayoutConstraint *horizontal = [NSLayoutConstraint constraintWithItem:item attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:centerTo attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
    NSLayoutConstraint *vertical = [NSLayoutConstraint constraintWithItem:item attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:centerTo attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
    return @[horizontal, vertical];
}

NSArray *constraintsCenterWithOffset(UIView *item, UIView *centerTo, CGFloat xOffset, CGFloat yOffset)
{
    NSLayoutConstraint *horizontal = [NSLayoutConstraint constraintWithItem:item attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:centerTo attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:xOffset];
    NSLayoutConstraint *vertical = [NSLayoutConstraint constraintWithItem:item attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:centerTo attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:yOffset];
    return @[horizontal, vertical];
}

NSLayoutConstraint *constraintCenterXWithOffset(UIView *item1, UIView *item2, CGFloat offset)
{
    return [NSLayoutConstraint constraintWithItem:item1 attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:item2 attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:offset];
}

NSLayoutConstraint *constraintCenterX(UIView *item1, UIView *item2)
{
    return constraintCenterXWithOffset(item1, item2, 0);
}


NSLayoutConstraint *constraintCenterYWithOffset(UIView *item1, UIView *item2, CGFloat offset)
{
    return [NSLayoutConstraint constraintWithItem:item1 attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:item2 attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:offset];
}

NSLayoutConstraint *constraintCenterY(UIView *item1, UIView *item2)
{
    return constraintCenterYWithOffset(item1, item2, 0);
}

NSLayoutConstraint *constraintLeadVertically(UIView *item1, UIView *item2, CGFloat offset)
{
    return [NSLayoutConstraint constraintWithItem:item1 attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:item2 attribute:NSLayoutAttributeTop multiplier:1.0 constant:offset];
}

NSLayoutConstraint *constraintLeadHorizontally(UIView *item1, UIView *item2, CGFloat offset)
{
    return [NSLayoutConstraint constraintWithItem:item1 attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:item2 attribute:NSLayoutAttributeLeft multiplier:1.0 constant:offset];
}

NSLayoutConstraint *constraintTrailVertically(UIView *item1, UIView *item2, CGFloat offset)
{
    return [NSLayoutConstraint constraintWithItem:item1 attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:item2 attribute:NSLayoutAttributeBottom multiplier:1.0 constant:offset];
}

NSLayoutConstraint *constraintTrailHorizontally(UIView *item1, UIView *item2, CGFloat offset)
{
     return [NSLayoutConstraint constraintWithItem:item1 attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:item2 attribute:NSLayoutAttributeRight multiplier:1.0 constant:offset];
}

NSLayoutConstraint *constraintHeight(UIView *item1, UIView *item2, CGFloat offset)
{
    NSLayoutAttribute secondAttribute = item2 ? NSLayoutAttributeHeight : NSLayoutAttributeNotAnAttribute;
    return [NSLayoutConstraint constraintWithItem:item1 attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:item2 attribute:secondAttribute multiplier:1.0 constant:offset];
}

NSLayoutConstraint *constraintTop(UIView *item1, UIView *item2, CGFloat offset)
{
    return [NSLayoutConstraint constraintWithItem:item1 attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:item2 attribute:NSLayoutAttributeTop multiplier:1.0 constant:offset];
}

NSLayoutConstraint *constraintBottom(UIView *item1, UIView *item2, CGFloat offset)
{
    return [NSLayoutConstraint constraintWithItem:item1 attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:item2 attribute:NSLayoutAttributeBottom multiplier:1.0 constant:offset];
}

NSLayoutConstraint *constraintLeft(UIView *item1, UIView *item2, CGFloat offset)
{
    return [NSLayoutConstraint constraintWithItem:item1 attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:item2 attribute:NSLayoutAttributeLeft multiplier:1.0 constant:offset];
}

NSLayoutConstraint *constraintRight(UIView *item1, UIView *item2, CGFloat offset)
{
    return [NSLayoutConstraint constraintWithItem:item1 attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:item2 attribute:NSLayoutAttributeRight multiplier:1.0 constant:offset];
}

NSLayoutConstraint *constraintAbsolute(UIView *item1, NSLayoutAttribute attribute, CGFloat offset)
{
    return [NSLayoutConstraint constraintWithItem:item1 attribute:attribute relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:offset];
}

NSArray *constraintsAbsoluteSize(UIView *item, CGFloat width, CGFloat height)
{
    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:item attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute: NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:width];
    
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:item attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute: NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:height];
    return @[widthConstraint, heightConstraint];
}

NSArray *constraintsEqualSize(UIView *item1, UIView *item2, CGFloat widthOffset, CGFloat heightOffset)
{
    NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:item1 attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:item2 attribute:item2 ? NSLayoutAttributeWidth : NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:widthOffset];
    
    NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:item1 attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:item2 attribute:item2 ? NSLayoutAttributeHeight : NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:heightOffset];
    return @[width, height];
}

NSArray *constraintsEqualPosition(UIView *item1, UIView *item2, CGFloat xOffset, CGFloat yOffset)
{
    NSLayoutConstraint *x = [NSLayoutConstraint constraintWithItem:item1 attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:item2 attribute:NSLayoutAttributeLeft multiplier:1.0 constant:xOffset];
    NSLayoutConstraint *y = [NSLayoutConstraint constraintWithItem:item1 attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:item2 attribute:NSLayoutAttributeTop multiplier:1.0 constant:yOffset];
    return @[x, y];
}

NSArray *constraintsEqualSizeAndPosition(UIView *item1, UIView *item2)
{
    NSMutableArray *array = [NSMutableArray new];
    [array addObjectsFromArray:constraintsEqualPosition(item1, item2, 0, 0)];
    [array addObjectsFromArray:constraintsEqualSize(item1, item2, 0, 0)];
    return array;
}

NSArray *constraintsHeightNotGreaterThanConstant(UIView *item1, UIView *item2, CGFloat constant)
{
    NSString *maxHeightFormat = [NSString stringWithFormat:@"V:[item1(<=%f)]", constant];
    NSArray *heightMaxConstraints = [NSLayoutConstraint constraintsWithVisualFormat:maxHeightFormat options:0 metrics:nil
                                                                              views:NSDictionaryOfVariableBindings(item1)];
    
    NSLayoutConstraint *heightDefaultConstraint = constraintHeight(item1, item2, 0);
    heightDefaultConstraint.priority = 900;
    return [@[heightDefaultConstraint] arrayByAddingObjectsFromArray:heightMaxConstraints];
}

NSArray *constraintsHeightGreaterThanOrEqual(UIView *item1, UIView *item2)
{
    NSString *heightFormat = [NSString stringWithFormat:@"V:[item1(>=item2)]"];
    NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:heightFormat options:0 metrics:nil
                                                                              views:NSDictionaryOfVariableBindings(item1, item2)];
    return constraints;

}
