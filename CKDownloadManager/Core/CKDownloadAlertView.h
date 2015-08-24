//
//  CKDownloadAlertView.h
//  chengkai
//
//  Created by mac on 15/1/9.
//  Copyright (c) 2015年 chengkai. All rights reserved.
//
//  You can alter this class to apply your own alert view . but you must keep it's interface.

#import <Foundation/Foundation.h>

typedef void(^DownloadAlertBlock)(id alertView);

@interface CKDownloadAlertView : NSObject

+ (instancetype)sharedInstance;

/**
 *  create alert view
 *
 *  @param title
 *  @param message
 *  @param cancelTitle
 *  @param sureTitle
 *  @param cancelBlock
 *  @param sureBlock
 *
 *  @return alert view
 */
+(CKDownloadAlertView *) alertViewWithTitle:(NSString *) title message:(NSString * ) message cancelButtonTitle:(NSString *) cancelTitle sureTitle:(NSString*) sureTitle cancelBlock:(DownloadAlertBlock) cancelBlock  sureBlock:(DownloadAlertBlock) sureBlock;

/**
 *  show alert view
 */
-(void) show;

/**
 *  dismiss alert view
 */
-(void) dismiss;

/**
 *  dismiss all presenting alert view
 */
+(void) dismissAllAlertView;

@end
