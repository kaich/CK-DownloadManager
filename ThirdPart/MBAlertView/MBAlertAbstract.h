//
//  MBAlertAbstract.h
//  Freebie
//
//  Created by Mo Bitar on 5/2/13.
//  Copyright (c) 2013 progenius. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

typedef enum {
    MBAlertAnimationTypeSmooth,
    MBAlertAnimationTypeBounce
} MBAlertAnimationType;

// notifications called when an alert/hud appears/disappears
extern NSString *const MBAlertDidAppearNotification;
extern NSString *const MBAlertDidDismissNotification;

@interface MBAlertAbstract : UIViewController
// perform something after the alert dismisses
@property (nonatomic, copy) id uponDismissalBlock;

// huds by default are put on super view controller. however sometimes a hud appears right before a modal disappears. in that case we'll add the hud to the window
@property (nonatomic, assign) BOOL addsToWindow;

// if yes, will wait until alert has disappeared before performing any button blocks
@property (nonatomic, assign) BOOL shouldPerformBlockAfterDismissal;

@property (nonatomic, strong) NSTimer *hideTimer;
@property (nonatomic, strong) UIView *parentView;
@property (nonatomic) MBAlertAnimationType animationType;

- (void)dismiss;
- (void)addToDisplayQueue;
- (void)show;

- (void)addToWindow;
- (void)performLayout;
- (BOOL)isOnScreen;


// dismisses current hud in queue, whether or not its visible
+ (void)dismissCurrentHUD;
+ (void)dismissCurrentHUDAfterDelay:(float)delay;

// yes if there is currently an alert or hud on screen
+ (BOOL)alertIsVisible;
@end
