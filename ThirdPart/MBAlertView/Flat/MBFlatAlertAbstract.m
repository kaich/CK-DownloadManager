
#import "MBFlatAlertAbstract.h"
#import "AutoLayoutHelpers.h"
#import <QuartzCore/QuartzCore.h>

@interface MBFlatAlertAbstract ()

@end

@implementation MBFlatAlertAbstract

- (UIView*)viewToApplyPresentationAnimationsOn
{
    return nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureBackgroundView];
}

- (void)configureBackgroundView
{
    self.backgroundView = [UIView newForAutolayoutAndAddToView:self.view];
    self.backgroundView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.4];
    self.backgroundView.alpha = 0.0;
    
    [self.view addConstraints:
     constraintsEqualSizeAndPosition(self.backgroundView, self.view)
     ];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [UIView animateWithDuration:0.25 animations:^{
        self.backgroundView.alpha = 1.0;
    }];
}

- (void)addDismissAnimation
{
    CGFloat const duration = 0.2;
    [UIView animateWithDuration:duration animations:^{
        self.backgroundView.alpha = 0.0;
    }];
    
    [[self viewToApplyPresentationAnimationsOn].layer addAnimation:[self.class flatDismissAnimation] forKey:@"anim"];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self performSelector:@selector(removeAlertFromView)];
    });
}

#define scale(x, y, z) [NSValue valueWithCATransform3D:CATransform3DMakeScale(x, y, z)]

+ (CAAnimation*)flatDismissAnimation
{
    NSArray *frameValues = @[scale(1.0, 1.0, 1.0), scale(0.7, 0.7, 0.7)];
    NSArray *frameTimes = @[@(0.0), @(1.0)];
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    animation.duration = 0.20;
    animation.keyTimes = frameTimes;
    animation.values = frameValues;
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    return animation;
}

@end
