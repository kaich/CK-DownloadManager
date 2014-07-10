//
//  CKLastTouchButton.h
//  aisiweb
//
//  Created by Mac on 14-6-30.
//  Copyright (c) 2014年 weiaipu. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^TouchupInsideActionBlock)(UIButton * sender);

@interface CKLastTouchButton : UIButton
-(void) setTouchUpInsideEveryTimeActionBlock:(TouchupInsideActionBlock) everyTimeAtionBlock  finalAcitonBlock:(TouchupInsideActionBlock) finalBlock;
@end
