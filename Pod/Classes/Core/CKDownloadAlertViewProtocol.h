//
//  CKDownloadAlertViewProtocol.h
//  Pods
//
//  Created by mac on 16/5/5.
//
//

#import <Foundation/Foundation.h>

typedef void(^DownloadAlertBlock)(id alertView);

@protocol CKDownloadAlertViewProtocol <NSObject>

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
+(id<CKDownloadAlertViewProtocol>) alertViewWithTitle:(NSString *) title message:(NSString * ) message cancelButtonTitle:(NSString *) cancelTitle sureTitle:(NSString*) sureTitle cancelBlock:(DownloadAlertBlock) cancelBlock  sureBlock:(DownloadAlertBlock) sureBlock;

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
