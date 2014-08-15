//
//  UIImage+Color.m
//  aisiweb
//
//  Created by Mac on 14-6-19.
//  Copyright (c) 2014年 weiaipu. All rights reserved.
//

#import "UIImage+Color.h"

@implementation UIImage (Color)

+ (UIImage *)imageWithColor:(UIColor *)color andSize:(CGSize)size contentRect:(CGRect) contentRect cornerRadius:(float) cornerRadius
{
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    addRoundedRectToPath(context, contentRect, cornerRadius,color);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}



+(UIImage*) lineImageWithSize:(CGSize) size  color:(UIColor*) color
{
    CGRect rect=CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, size.height);
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    CGContextMoveToPoint(context,0, 0);
    CGContextAddLineToPoint(context, size.width, 0);
    CGContextStrokePath(context);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}


static void addRoundedRectToPath(CGContextRef context, CGRect rect,
                                 float cornerRadius, UIColor * color)
{
    
    float red ,green ,blue,alpha;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    
    float width=rect.size.width;
    float height=rect.size.height;
    float originX=rect.origin.x;
    float originY=rect.origin.y;
    
 
    CGContextMoveToPoint(context, originX+ cornerRadius, originY);
    
  
    CGContextAddLineToPoint(context, originX+ width - cornerRadius, originY);
    CGContextAddArc(context,originX+ width - cornerRadius,originY+ cornerRadius, cornerRadius, -0.5 * M_PI, 0.0, 0);
    
    
    CGContextAddLineToPoint(context,originX+ width, originY+ height - cornerRadius);
    CGContextAddArc(context,originX+ width - cornerRadius,originY+ height - cornerRadius, cornerRadius, 0.0, 0.5 * M_PI, 0);
    
   
    CGContextAddLineToPoint(context,originX+ cornerRadius,originY+ height);
    CGContextAddArc(context,originX+ cornerRadius, originY+ height - cornerRadius, cornerRadius, 0.5 * M_PI, M_PI, 0);
    
    
    CGContextAddLineToPoint(context, originX,originY+ cornerRadius);
    CGContextAddArc(context,originX+ cornerRadius, originY+ cornerRadius, cornerRadius, M_PI, 1.5 * M_PI, 0);
    
    
    CGContextClosePath(context);
    
    CGContextSetRGBFillColor(context, red, green, blue, alpha);
    CGContextDrawPath(context, kCGPathFill);
}

@end
