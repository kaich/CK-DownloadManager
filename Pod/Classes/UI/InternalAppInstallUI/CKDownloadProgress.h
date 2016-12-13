//
//  CKDownloadProgress.h
//  chengkai
//
//  Created by Mac on 14-6-17.
//  Copyright (c) 2014年 chengkai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKDownloadProgressViewProtocol.h"

@interface CKDownloadProgress : UIView<CKDownloadProgressViewProtocol>
@property(nonatomic,strong) UIColor * progressColor;

-(void) setProgress:(CGFloat) progress animated:(BOOL)animated;
@end
