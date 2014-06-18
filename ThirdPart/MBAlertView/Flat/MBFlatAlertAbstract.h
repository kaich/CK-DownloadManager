
#import "MBAlertAbstract.h"
@class CAAnimation;

@interface MBFlatAlertAbstract : MBAlertAbstract
@property (nonatomic, strong) UIView *backgroundView;
- (void)addDismissAnimation;
- (UIView*)viewToApplyPresentationAnimationsOn;
- (void)configureBackgroundView;
+ (CAAnimation*)flatDismissAnimation;
@end
