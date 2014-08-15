//
//  UIImage+Color.h
//  aisiweb
//
//  Created by Mac on 14-6-19.
//  Copyright (c) 2014年 weiaipu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Color)
/**
 *  通过颜色来创建对应的图像
 *
 *  @param color        颜色
 *  @param size         整体的大小
 *  @param contentRect  颜色区域
 *  @param cornerRadius 圆角半径
 *
 *  @return 返回图像
 */
+ (UIImage *)imageWithColor:(UIColor *)color andSize:(CGSize)size contentRect:(CGRect) contentRect cornerRadius:(float) cornerRadius;

/**
 *  通过颜色值来获得线状的图像
 *
 *  @param size  线的长宽
 *  @param color 颜色值
 *
 *  @return 线的图像
 */
+(UIImage*) lineImageWithSize:(CGSize) size  color:(UIColor*) color;
@end
