//
//  CKDownloadProgress.h
//  aisiweb
//
//  Created by Mac on 14-6-17.
//  Copyright (c) 2014年 weiaipu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CKDownloadProgress : UIView
{
    float _progress;
}
@property(nonatomic) float progress;
@property(nonatomic,strong) UIColor * progressColor;
@end
