//
//  CKValidatorModel.h
//  aisiweb
//
//  Created by mac on 15/1/4.
//  Copyright (c) 2015年 weiaipu. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CKValidatorModelProtocal <NSObject>
/**
 *  standard file size
 */
@property(nonatomic,assign) long long standardFileSize;

/**
 *  standard file content validation code 
 */
@property(nonatomic,strong) NSString * standardFileValidationCode;
@end
