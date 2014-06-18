//
//  MBAlertView.m
//  Notestand
//
//  Created by Mo Bitar on 9/8/12.
//  Copyright (c) 2012 progenius, inc. All rights reserved.
//

#import "MBAlertView.h"
#import "MBHUDView.h"
#import <QuartzCore/QuartzCore.h>

#import "MBAlertViewButton.h"
#import "MBSpinningCircle.h"
#import "MBCheckMarkView.h"

#import "NSString+Trim.h"
#import "UIFont+Alert.h"

#import "MBAlertViewSubclass.h"
#import "UIView+Alert.h"

CGFloat MBAlertViewMaxHUDDisplayTime = 10.0;
CGFloat MBAlertViewDefaultHUDHideDelay = 0.65;

@interface MBAlertView ()
@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIView *modalBackground;
@property (nonatomic, strong) UIView *buttonCollectionView;
@end

@implementation MBAlertView {
    NSMutableArray *_buttons;
}

// when dismiss is called, it takes about 0.5 seconds to complete animations. you want to remove it from the queue in the beginning, but want something to hold on to it. this is what retain queue is for

@synthesize size = _size;
@synthesize contentView = _contentView;
@synthesize modalBackground = _modalBackground;
@synthesize buttonCollectionView = _buttonCollectionView;

#pragma mark - Property Accessors
- (UIView *)buttonCollectionView {
    if (!_buttonCollectionView){
        _buttonCollectionView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, self.contentView.bounds.size.width, 20)];
    }
    return _buttonCollectionView;
}

- (CGSize)size {
    if (CGSizeEqualToSize(_size, CGSizeZero)){
        if (self.contentView){
            _size = self.contentView.frame.size;
        }
    }
    return _size;
}

+ (CGSize)halfScreenSize {
    return CGSizeMake(280, 240);
}

+ (MBAlertView*)alertWithBody:(NSString*)body cancelTitle:(NSString*)cancelTitle cancelBlock:(void (^)())cancelBlock {
    MBAlertView *alert = [[MBAlertView alloc] init];
    alert.bodyText = body;
    if(cancelTitle)
        [alert addButtonWithText:cancelTitle type:MBAlertViewItemTypeDefault block:cancelBlock];
    return alert;
}

- (void)didSelectButton:(MBAlertViewButton*)button {
    if(button.tag >= _items.count)
        return;
    MBAlertViewItem *item = [_items objectAtIndex:button.tag];
    if(!item)
        return;
    
    id block = item.block;
    if (![block isEqual:[NSNull null]] && block) {
        if(self.shouldPerformBlockAfterDismissal && block)
            self.uponDismissalBlock = block;
        else ((void (^)())block)();
        [[NSNotificationCenter defaultCenter] postNotificationName:MBAlertDidDismissNotification object:nil];
    }
    else {
        [[NSNotificationCenter defaultCenter] postNotificationName:MBAlertDidDismissNotification object:nil];
    }
    
    [self performSelector:@selector(dismiss) withObject:nil afterDelay:0.12];
}


// if there is only one button on the alert, we're going to assume its just an OK option, so we'll let the user tap anywhere to dismiss the alert
- (void)didTapOutsideOfButtons:(UITapGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        if(_buttons.count == 1) {
            MBAlertViewButton *alertButton = [_buttons objectAtIndex:0];
            [self didSelectButton:alertButton];
        }
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    // test if our control subview is on-screen
    if ([touch.view isKindOfClass:[MBAlertViewButton class]]) {
        // we touched a button
        return NO; // ignore the touch
    }
    return YES; // handle the touch
}

- (NSMutableArray*)items {
    if(_items)
        return _items;
    _items = [[NSMutableArray alloc] init];
    return _items;
}

- (void)addButtonWithText:(NSString*)text type:(MBAlertViewItemType)type block:(void (^)())block {
    MBAlertViewItem *item = [[MBAlertViewItem alloc] initWithTitle:text type:type block:block];
    [self.items addObject:item];
}

- (int)defaultAutoResizingMask {
    return UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
}

- (int)fullAutoResizingMask {
    return UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
}

#define kBodyFont [UIFont boldSystemFontOfSize:20]
#define kSpaceBetweenButtons 30
#define kVerticalSpaceBetweenButtons 20

- (BOOL)sizeNotSet {
    return CGSizeEqualToSize(self.size, CGSizeZero);
}

- (void)performLayout {
    [self performLayoutOfButtons];
    [self centerViewsVertically];
}

- (void)loadView {
    CGRect bounds = [[UIScreen mainScreen] bounds];
    self.view = [[UIView alloc] initWithFrame:bounds];
    
    [self.view setBackgroundColor:[UIColor clearColor]];
    self.view.autoresizingMask = [self fullAutoResizingMask];
    
    if([self sizeNotSet]) {
        self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, bounds.size.width, bounds.size.height)];
        
        self.modalBackground = [[UIView alloc] initWithFrame:CGRectMake(-100, -100, bounds.size.width + 200, bounds.size.height + 200)];
    }
    else {
        self.contentView = [[UIView alloc] initWithFrame:CGRectMake(bounds.size.width/2.0 - self.size.width/2.0 , bounds.size.height/2.0 - self.size.height/2.0, self.size.width, self.size.height)];
        
        self.modalBackground = [[UIView alloc] initWithFrame:self.contentView.frame];
        self.modalBackground.layer.cornerRadius = 8;
    }
    
    [self.modalBackground setBackgroundColor:[UIColor blackColor]];
    self.modalBackground.alpha = _backgroundAlpha > 0 ? _backgroundAlpha : 0.0;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOutsideOfButtons:)];
    [tap setCancelsTouchesInView:NO];
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
    
    [self.view addSubview:self.modalBackground];
    [self.view addSubview:self.contentView];
    
    self.modalBackground.autoresizingMask = [self fullAutoResizingMask];
    self.contentView.autoresizingMask = [self fullAutoResizingMask];
}

- (UIFont*)bodyFont {
    if(_bodyFont)
        return _bodyFont;
    _bodyFont = [UIFont boldSystemFontThatFitsSize:[self labelConstraint] maxFontSize:22 minSize:20 text:self.bodyText];
    return _bodyFont;
}

- (CGSize)labelConstraint {
    CGSize size = self.contentView.bounds.size;
    return CGSizeMake(size.width-40, size.height);
}

- (UIButton*)bodyLabelButton {
    if(_bodyLabelButton)
        return _bodyLabelButton;
    
    CGRect content = self.contentView.bounds;
    
    CGSize size = [_bodyText sizeWithFont:self.bodyFont constrainedToSize:[self labelConstraint]];
    
    NSString *txt = [_bodyText stringByTruncatingToSize:size withFont:self.bodyFont addQuotes:NO];
    _bodyLabelButton = [[UIButton alloc] initWithFrame:CGRectMake(content.origin.x + content.size.width/2.0 - size.width/2.0, content.origin.y + content.size.height/2.0 - size.height/2.0 - 8, size.width, size.height)];
    _bodyLabelButton.autoresizingMask = [self defaultAutoResizingMask];
    [_bodyLabelButton addTarget:self action:@selector(didSelectBodyLabel:) forControlEvents:UIControlEventTouchUpInside];
    [_bodyLabelButton setTitle:_bodyText forState:UIControlStateNormal];
    
    _bodyLabelButton.titleLabel.text = txt;
    _bodyLabelButton.titleLabel.font = self.bodyFont;
    _bodyLabelButton.titleLabel.numberOfLines = 0;
    _bodyLabelButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [_bodyLabelButton setBackgroundColor:[UIColor clearColor]];
    return _bodyLabelButton;
}

- (UIImageView*)imageView {
    if(_imageView)
        return _imageView;
    _imageView = [[UIImageView alloc] init];
    return _imageView;
}

- (void)layoutView {
    if(_imageView) {
        [_imageView sizeToFit];
        CGRect rect = self.imageView.frame;
        rect.origin = CGPointMake((self.contentView.frame.size.width/2.0 - rect.size.width/2.0), 0);
        _imageView.frame = rect;
        [self.contentView addSubview:self.imageView];
        self.imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    }
        
    UIColor *titleColor = [UIColor whiteColor];
    [self.bodyLabelButton setTitleColor:titleColor forState:UIControlStateNormal];
    [self.contentView addSubview:self.bodyLabelButton];
    
    _buttons = [[NSMutableArray alloc] init];
    [self.items enumerateObjectsUsingBlock:^(MBAlertViewItem *item, NSUInteger index, BOOL *stop) {
         MBAlertViewButton *buttonLabel = [[MBAlertViewButton alloc] initWithTitle:item.title];
         
         [buttonLabel addTarget:self action:@selector(didSelectButton:) forControlEvents:UIControlEventTouchUpInside];
         [buttonLabel addTarget:self action:@selector(didHighlightButton:) forControlEvents:UIControlEventTouchDown];
         [buttonLabel addTarget:self action:@selector(didRemoveHighlightFromButton:) forControlEvents:UIControlEventTouchUpOutside | UIControlEventTouchDragExit | UIControlEventTouchCancel];
         
         buttonLabel.tag = index;
         buttonLabel.alertButtonType = item.type;
         
         [_buttons addObject:buttonLabel];
     }];
}

- (void)centerViewsVertically {
    NSMutableArray *viewsToCenter = [@[] mutableCopy];
    if (_imageView) {
        [viewsToCenter addObject:@{@"view": _imageView, @"offset": @0}];
    }
    [viewsToCenter addObject:@{@"view": self.bodyLabelButton, @"offset": (_imageView ? @20 : @0)}];
    
    if ([self.buttonCollectionView.subviews count]){
        [viewsToCenter addObject:@{
         @"view": self.buttonCollectionView,
         @"offset": @20
         }];
    };
    
    [self.contentView centerViewsVerticallyWithin:viewsToCenter];
}

// lays out button on rotation
- (void)layoutButtonsWrapper {
    [UIView animateWithDuration:0.3 animations:^{
        [self performLayoutOfButtons];
    }];
    [self centerViewsVertically];
}

- (void)layoutButtonCollecitonView {
    CGSize contentSize = self.contentView.bounds.size;
    CGFloat contentHeight = contentSize.height;
    CGFloat butttonCollectionHeight = contentHeight;
    butttonCollectionHeight -= self.imageView.frame.size.height ? (self.imageView.frame.size.height - 20) : 0;
    CGFloat bodyLabelButtonHeight = self.bodyLabelButton.frame.size.height;
    butttonCollectionHeight -= bodyLabelButtonHeight+20;
    
    self.buttonCollectionView.frame = CGRectMake(0, 0, contentSize.width, butttonCollectionHeight-20);
}

- (void)performLayoutOfButtons {
    if ([_buttons count] <= 0) return;
    
    [self layoutButtonCollecitonView];
    CGRect bounds = self.buttonCollectionView.bounds;
    CGSize spacing = CGSizeMake(kSpaceBetweenButtons, kVerticalSpaceBetweenButtons);
    
    // reset butons to default height/width
    for(MBAlertViewButton *item in _buttons) {
        item.frame = CGRectMake(0, 0, 100, 40);
    }
    
    CGSize totalSize = [self totalSize:_buttons withSpacing:spacing];
    
    NSMutableArray *buttonGrid;
    
    if (totalSize.width < bounds.size.width) {
        buttonGrid = [self createSingleRowOfButtons];
    }
    else if (totalSize.height < bounds.size.height)
    {
        buttonGrid = [self createSingleColumnOfButtons];
    }
    else {
        buttonGrid = [self createGridOfButtons];
    }
    
    __block CGFloat currentYOrigin = 0;
    __block CGFloat widthOfLastRow = 0;
    
    [buttonGrid enumerateObjectsUsingBlock:^(NSMutableArray *row, NSUInteger idx, BOOL *stop) {
        __block CGFloat heightOfLastRow = 0;
        
        __block CGSize rowTotalSize = [self totalSize:row withSpacing:spacing];
        
        CGFloat xOrigOfFirstItem = bounds.size.width/2.0 - rowTotalSize.width/2.0;
        
        __block CGFloat currentXOrigin = xOrigOfFirstItem;
        
        // show big buttons if only one colum (and more than one button)
        __block BOOL only1InRow = ([row count] == 1 && [buttonGrid count] > 1);
        
        [row enumerateObjectsUsingBlock:^(MBAlertViewButton *button, NSUInteger index, BOOL *stop) {
            CGFloat xOrigin = currentXOrigin;
            CGFloat yOrigin = currentYOrigin;
            
            CGRect rect = button.frame;
            CGSize size = rect.size;
            CGFloat width = size.width;
            CGFloat height = size.height;
            
            if (only1InRow) {
                if (widthOfLastRow > 0) {
                    width = widthOfLastRow;
                    xOrigin = bounds.size.width/2.0 - width/2.0;
                    rowTotalSize.width = width;
                } else {
                    width = bounds.size.width - 2*kSpaceBetweenButtons;
                    xOrigin = bounds.origin.x + kSpaceBetweenButtons;
                    rowTotalSize.width = width;
                }
            }
            
            rect.size = CGSizeMake(width, height);
            rect.origin = CGPointMake(xOrigin, yOrigin);
            button.frame = rect;
            
            button.autoresizingMask = UIViewAutoresizingNone;
            [self.buttonCollectionView addSubview:button];
            [button setNeedsDisplay];
            
            // Setup for next pass
            // get the tallest of all buttons in case they are different sizes
            CGFloat rowHeight = height + kVerticalSpaceBetweenButtons;
            if (rowHeight > heightOfLastRow) heightOfLastRow = rowHeight;
            currentXOrigin += width + kSpaceBetweenButtons;
        }];
        
        // set up for next row
        widthOfLastRow = rowTotalSize.width;
        currentYOrigin += heightOfLastRow;
    }];
    
    CGFloat requiredHeight = currentYOrigin;
    CGRect bcvFrame = self.buttonCollectionView.frame;
    bcvFrame.size.height = requiredHeight;
    self.buttonCollectionView.frame = bcvFrame;
    
    [self.contentView addSubview:self.buttonCollectionView];
    self.buttonCollectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (NSMutableArray *)createSingleRowOfButtons {
    NSMutableArray *buttonGrid = [@[ [@[] mutableCopy] ] mutableCopy];
    for(MBAlertViewButton *item in _buttons) {
        [[buttonGrid lastObject] addObject:item];
    }
    return buttonGrid;
}

- (NSMutableArray *)createSingleColumnOfButtons {
    NSMutableArray *buttonGrid = [@[] mutableCopy];
    for(MBAlertViewButton *item in _buttons) {
        [buttonGrid addObject:[@[item] mutableCopy]];
    }
    return buttonGrid;
}

- (NSMutableArray *)createGridOfButtons {
    NSMutableArray *buttonGrid = [@[ [@[] mutableCopy] ] mutableCopy];
    
    CGRect bounds = self.view.bounds;
    float maxWidthOnGrid = bounds.size.width;
    
    float buttonGridWidthTotal = 0;
    
    for(MBAlertViewButton *item in _buttons) {
        CGSize size = item.frame.size;
        buttonGridWidthTotal += size.width + kSpaceBetweenButtons;
        
        if (buttonGridWidthTotal <= maxWidthOnGrid) {
            [[buttonGrid lastObject] addObject:item];
        } else {
            [buttonGrid addObject:[@[item] mutableCopy]];
            buttonGridWidthTotal = size.width;
        }
    }
    
    return buttonGrid;
}

- (CGSize)totalSize:(NSArray *)views withSpacing:(CGSize)spacing {
    float totalWidth = 0;
    float totalHeight = 0;
    
    for(UIView *view in views) {
        CGSize size = view.frame.size;
        totalWidth += size.width + spacing.width;
        totalHeight += size.height + spacing.height;
    }
    // space only between items
    totalWidth -= spacing.width;
    totalHeight -= spacing.height;
    
    return CGSizeMake(totalWidth, totalHeight);
}

- (CGSize)totalSize:(NSArray *)views {
    return [self totalSize:views withSpacing:CGSizeZero];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self layoutView];
}

@end