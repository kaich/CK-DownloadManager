
#import <UIKit/UIKit.h>

typedef void (^MBFlatAlertButtonAction)();

typedef enum {
    MBFlatAlertButtonTypeNormal,
    MBFlatAlertButtonTypeBold,
    MBFlatAlertButtonTypeRed,
    MBFlatAlertButtonTypeGreen,
} MBFlatAlertButtonType;

@interface MBFlatAlertButton : UIButton
@property (nonatomic, copy) MBFlatAlertButtonAction action;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic) MBFlatAlertButtonType type;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic) BOOL hasRightStroke;
@property (nonatomic) BOOL hasBottomStroke;

+ (UIColor*)defaultTextColor;

+ (instancetype)buttonWithTitle:(NSString*)title type:(MBFlatAlertButtonType)type action:(MBFlatAlertButtonAction)action;
@end
