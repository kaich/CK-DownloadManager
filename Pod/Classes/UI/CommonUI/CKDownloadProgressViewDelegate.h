//
//  CKDownloadProgressViewDelegate.h
//  Pods
//
//  Created by mac on 15/9/11.
//
//

#import <Foundation/Foundation.h>

@protocol CKDownloadProgressViewDelegate <NSObject>

@required

- (void)setProgress:(float)progress animated:(BOOL)animated ;

@end
