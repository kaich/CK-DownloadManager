//
//  CKDownloadAlertView.m
//  aisiweb
//
//  Created by mac on 15/1/9.
//  Copyright (c) 2015年 weiaipu. All rights reserved.
//

#import "CKDownloadAlertView.h"
#import "DTAlertView.h"


@interface CKDownloadAlertView ()
@property(nonatomic,strong) id alertView;
@end

@implementation CKDownloadAlertView


+ (instancetype)sharedInstance {
    static CKDownloadAlertView *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[CKDownloadAlertView alloc] init];
    });
    
    return _sharedInstance;
}


+(CKDownloadAlertView *) alertViewWithTitle:(NSString *) title message:(NSString * ) message cancelButtonTitle:(NSString *) cancelTitle sureTitle:(NSString*) sureTitle cancelBlock:(DownloadAlertBlock) cancelBlock  sureBlock:(DownloadAlertBlock) sureBlock
{
    CKDownloadAlertView * alertViewAdapter = [CKDownloadAlertView sharedInstance];
    
    alertViewAdapter.alertView=[DTAlertView alertViewUseBlock:^(DTAlertView *alertView, NSUInteger buttonIndex, NSUInteger cancelButtonIndex) {
        if(buttonIndex==0)
        {
            if(cancelBlock)
                cancelBlock(alertView);
        }
        else
        {
            if(sureBlock)
                sureBlock(alertView);
        }
        
    } title:title message:message cancelButtonTitle:cancelTitle positiveButtonTitle:sureTitle];
    return alertViewAdapter ;
}

-(void) show
{
    [self.alertView show];
}

-(void) dismiss
{
    [self.alertView dismiss];
}

+(void) dismissAllAlertView
{
    [DTAlertView dismissAllAlertView];
}

@end
