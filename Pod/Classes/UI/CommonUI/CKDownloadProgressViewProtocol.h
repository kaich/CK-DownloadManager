//
//  CKDownloadProgressViewDelegate.h
//  Pods
//
//  Created by mac on 15/9/11.
//
//

#import <Foundation/Foundation.h>

@protocol CKDownloadProgressViewProtocol <NSObject>

@required

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated ;

@end
