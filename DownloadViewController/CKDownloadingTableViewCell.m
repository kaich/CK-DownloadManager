//
//  CKDownloadingTableViewCell.m
//  aisiweb
//
//  Created by Mac on 14-6-17.
//  Copyright (c) 2014年 weiaipu. All rights reserved.
//

#import "CKDownloadingTableViewCell.h"

#ifndef SCREEN_WIDTH
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#endif


@interface CKDownloadingTableViewCell ()
@property(nonatomic,strong) CKDownloadProgress * pgDownloadProgress;
@end

@implementation CKDownloadingTableViewCell
@dynamic progress;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        self.lblDownloadVersion=[[UILabel alloc] initWithFrame:CGRectMake(self.lblTitle.frame.origin.x, 37, 50, 10)];
        self.lblDownloadVersion.font=[UIFont systemFontOfSize:9];
        self.lblDownloadVersion.backgroundColor=[UIColor clearColor];
        self.lblDownloadVersion.textColor=[UIColor blackColor];
        [self.contentView addSubview:self.lblDownloadVersion];
        
        
        self.lblDownloadStatus=[[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-65-50, 50, 50, 10)];
        self.lblDownloadStatus.font=[UIFont systemFontOfSize:9];
        self.lblDownloadStatus.backgroundColor=[UIColor clearColor];
        self.lblDownloadStatus.textColor=[UIColor lightGrayColor];
        [self.contentView addSubview:self.lblDownloadStatus];
        
        
        self.lblRestTime=[[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-100, 65, 90, 10)];
        self.lblRestTime.font=[UIFont systemFontOfSize:9];
        self.lblRestTime.textAlignment=NSTextAlignmentRight;
        self.lblRestTime.backgroundColor=[UIColor clearColor];
        self.lblRestTime.textColor=[UIColor lightGrayColor];
        [self.contentView addSubview:self.lblRestTime];
        
        
        self.pgDownloadProgress=[[CKDownloadProgress alloc] initWithFrame:CGRectMake(5, self.frame.size.height-10, SCREEN_WIDTH-10, 10)];
        self.pgDownloadProgress.autoresizingMask=UIViewAutoresizingFlexibleTopMargin;
        [self.contentView addSubview:self.pgDownloadProgress];
        
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


#pragma mark - dynamic method
-(void) setProgress:(float)progress
{
    _progress=progress;
    self.pgDownloadProgress.progress=progress;
}

-(float) progress
{
    return _progress;
}




#pragma mark -  class method
+(float) getHeight
{
    return  93;
}


@end
