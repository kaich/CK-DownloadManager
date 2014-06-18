
#import "UIView+Autolayout.h"

@implementation UIView (Autolayout)
+ (id)newForAutolayoutAndAddToView:(UIView*)view
{
    UIView *obj = [self new];
    obj.translatesAutoresizingMaskIntoConstraints = NO;
    [view addSubview:obj];
    return obj;
}
@end
