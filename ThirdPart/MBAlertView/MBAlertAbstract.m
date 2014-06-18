//
//  MBAlertAbstract.m
//  Freebie
//
//  Created by Mo Bitar on 5/2/13.
//  Copyright (c) 2013 progenius. All rights reserved.
//

#import "MBAlertAbstract.h"
#import "MBAlertViewSubclass.h"
#import "MBHUDView.h"
#import "MBAlertViewButton.h"
#import "UIView+Alert.h"
#import <QuartzCore/QuartzCore.h>

NSString *const MBAlertDidAppearNotification = @"MBAlertDidAppearNotification";
NSString *const MBAlertDidDismissNotification = @"MBAlertDidDismissNotification";

@interface MBAlertAbstract ()
@property (nonatomic, assign) BOOL viewHasLoaded;
@end

@implementation MBAlertAbstract {
    BOOL isPendingDismissal;
}

static NSMutableArray *retainQueue;
static NSMutableArray *displayQueue;
static NSMutableArray *dismissQueue;
static MBAlertAbstract *currentAlert;

#define kDismissDuration 0.25

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)init {
    if(self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setRotation:)name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    }
    
    return self;
}

- (void)addToDisplayQueue
{
    [self initQueues];
    
    [displayQueue addObject:self];
    [dismissQueue addObject:self];
    
    if(retainQueue.count == 0 && !currentAlert) {
        // show now
        currentAlert = self;
        [self addToWindow];
        [[NSNotificationCenter defaultCenter] postNotificationName:MBAlertDidAppearNotification object:self];
    }
}

- (void)initQueues
{
    if(!displayQueue)
        displayQueue = [[NSMutableArray alloc] init];
    if(!dismissQueue)
        dismissQueue = [[NSMutableArray alloc] init];
}

- (void)show
{
    [self initQueues];
    [dismissQueue addObject:self];
    [self addToWindow];
}

- (void)addToWindow
{
    UIWindow * window = [UIApplication sharedApplication].keyWindow;
    if (!window)
        window = [[UIApplication sharedApplication].windows objectAtIndex:0];


    if(self.parentView)
        [self addToView:self.parentView];
    else [self addToView:window];
//    else [self addToView:[[window subviews] objectAtIndex:0]];
}

- (void)addToView:(UIView*)view
{
    [view addSubview:self.view];
    
    [self performLayout];
    
    [view resignFirstRespondersForSubviews];
    
    [self addPresentAnimation];
    
    [displayQueue removeObject:self];
}

- (void)addPresentAnimation {
    
    [self addAnimationToLayer:self.view.layer];
}

- (void)performLayout {
    
}

- (void)dismiss
{
    if(isPendingDismissal)
        return;
    
    isPendingDismissal = YES;
    
    if(!retainQueue)
        retainQueue = [[NSMutableArray alloc] init];
    
    [self.hideTimer invalidate];
    [retainQueue addObject:self];
    [dismissQueue removeObject:self];
    
    if([self isEqual:currentAlert])
        currentAlert = nil;
    
    [self addDismissAnimation];
}

- (void)removeAlertFromView
{
    id block = self.uponDismissalBlock;
    if (![block isEqual:[NSNull null]] && block) {
        ((void (^)())block)();
    }
    
    [self.view removeFromSuperview];
    [retainQueue removeObject:self];
    
    if(displayQueue.count > 0) {
        MBAlertAbstract *alert = [displayQueue objectAtIndex:0];
        currentAlert = alert;
        [currentAlert addToWindow];
    }
}

- (BOOL)isOnScreen
{
    return [currentAlert isEqual:self];
}

+ (void)dismissCurrentHUD {
    if(dismissQueue.count > 0) {
        MBAlertAbstract *current = [dismissQueue lastObject];
        [displayQueue removeObject:current];
        [current dismiss];
        [dismissQueue removeLastObject];
    }
}

+ (void)dismissCurrentHUDAfterDelay:(float)delay {
    [[MBAlertAbstract class] performSelector:@selector(dismissCurrentHUD) withObject:nil afterDelay:delay];
}

+ (BOOL)alertIsVisible {
    if(currentAlert)
        return YES;
    return NO;
}

- (void)didRemoveHighlightFromButton:(MBAlertViewButton*)button {
    [button.layer removeAllAnimations];
}

- (void)setRotation:(NSNotification*)notification {
    if (self.viewHasLoaded){
        [self performSelector:@selector(layoutButtonsWrapper) withObject:nil afterDelay:0.01];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.viewHasLoaded = YES;
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return (UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown | UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight);
}

#pragma mark - Animations

- (void)hideWithFade
{
    self.view.alpha = 0.0;
    [self addFadingAnimationWithDuration:[self isMemberOfClass:[MBHUDView class]] ? 0.25 : 0.20];
    [self performSelector:@selector(removeAlertFromView) withObject:nil afterDelay:kDismissDuration];
}

#define transform(x, y, z) [NSValue valueWithCATransform3D:CATransform3DMakeScale(x, y, z)]

- (void)addDismissAnimation
{
    [self.view.layer addAnimation:[self dismissAnimationForType:self.animationType] forKey:@"popup"];
    [self performSelector:@selector(hideWithFade) withObject:nil afterDelay:0.15];
}

CAAnimation *fadeAnimation()
{
    CABasicAnimation *basicAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    basicAnimation.fromValue = @(1.0);
    basicAnimation.toValue = @(0.0);
    basicAnimation.duration = 0.;
    return basicAnimation;
}

CAAnimation *bounceAnimation() {
    NSArray *frameValues = @[transform(0.1, 0.1, 0.1), transform(1.15, 1.15, 1.15), transform(0.9, 0.9, 0.9), transform(1.0, 1.0, 1.0)];
    NSArray *frameTimes = @[@(0.0), @(0.5), @(0.9), @(1.0)];
    return [MBAlertAbstract animationWithValues:frameValues times:frameTimes duration:0.4];
}

CAAnimation *bounceDismissAnimation()
{
    NSArray *frameValues = @[transform(1.0, 1.0, 1), transform(0.95, 0.95, 1), transform(1.15, 1.15, 1), transform(0.01, 0.01, 1.0)];
    NSArray *frameTimes = @[@(0.0), @(0.1), @(0.5), @(1.0)];
    CAKeyframeAnimation *animation = [MBAlertAbstract animationWithValues:frameValues times:frameTimes duration:kDismissDuration];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    return animation;
}

CAAnimation *smoothPresentAnimation() {
    NSArray *frameValues = @[transform(1.1, 1.1, 1.1), transform(1.0, 1.0, 1.0)];
    NSArray *frameTimes = @[@(0.0), @(1.0)];
    return [MBAlertAbstract animationWithValues:frameValues times:frameTimes duration:0.3];
}

CAAnimation *smoothDismissAnimation() {
    NSArray *frameValues = @[transform(1.0, 1.0, 1.0), transform(0.0, 0.0, 0.0)];
    NSArray *frameTimes = @[@(0.0), @(1.0)];
    return [MBAlertAbstract animationWithValues:frameValues times:frameTimes duration:0.25];
}

- (CAAnimation*)presentAnimationForType:(MBAlertAnimationType)type {
    if(type == MBAlertAnimationTypeBounce)
        return bounceAnimation();
    else return smoothPresentAnimation();
}

- (CAAnimation*)dismissAnimationForType:(MBAlertAnimationType)type {
    if(type == MBAlertAnimationTypeBounce)
        return bounceDismissAnimation();
    else return smoothDismissAnimation();
}

- (void)addAnimationToLayer:(CALayer*)layer {
    [layer addAnimation:[self presentAnimationForType:self.animationType] forKey:@"popup"];
}

- (void)didSelectBodyLabel:(UIButton*)bodyLabelButton {
    NSArray *frameValues = @[transform(1.0, 1.0, 1), transform(1.08, 1.08, 1), transform(0.95, 0.95, 1), transform(1.02, 1.02, 1), transform(1.0, 1.0, 1)];
    NSArray *frameTimes = @[@(0.0), @(0.1), @(0.7), @(0.9), @(1.0)];
    [bodyLabelButton.layer addAnimation:[self.class animationWithValues:frameValues times:frameTimes duration:0.3] forKey:@"popup"];
}

- (void)didHighlightButton:(MBAlertViewButton*)button {
    NSArray *frameValues = @[transform(1.0, 1.0, 1), transform(1.25, 1.25, 1.0)];
    NSArray *frameTimes = @[@(0.0), @(0.5)];
    [button.layer addAnimation:[self.class animationWithValues:frameValues times:frameTimes duration:0.25] forKey:@"popup"];
}

- (void)addFadingAnimationWithDuration:(CGFloat)duration {
    CATransition *animation = [CATransition animation];
    animation.type = kCATransitionFade;
    animation.subtype = kCATransitionFromBottom;
    animation.duration = duration;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.fillMode = @"extended";
    animation.removedOnCompletion = YES;
    [self.view.layer addAnimation:animation forKey:@"reloadAnimation"];
}

+ (CAKeyframeAnimation*)animationWithValues:(NSArray*)values times:(NSArray*)times duration:(CGFloat)duration {
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    animation.values = values;
    animation.keyTimes = times;
    animation.fillMode = kCAFillModeForwards;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    animation.removedOnCompletion = NO;
    animation.duration = duration;
    return animation;
}

@end
