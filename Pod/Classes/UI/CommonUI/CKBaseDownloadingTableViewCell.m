//
//  CKDownloadingTableViewCell.m
//  chengkai
//
//  Created by Mac on 14-6-17.
//  Copyright (c) 2014年 chengkai. All rights reserved.
//

#import "CKBaseDownloadingTableViewCell.h"

#ifndef SCREEN_WIDTH
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#endif


@interface CKBaseDownloadingTableViewCell ()
@end

@implementation CKBaseDownloadingTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        
        UILabel * lblDownloadStatus=[[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-65-50, 50, 50, 10)];
        lblDownloadStatus.font=[UIFont systemFontOfSize:9];
        lblDownloadStatus.backgroundColor=[UIColor clearColor];
        lblDownloadStatus.textColor=[UIColor lightGrayColor];
        [self.contentView addSubview:lblDownloadStatus];
        self.lblDownloadStatus = lblDownloadStatus;
        
        
        UILabel * lblRestTime=[[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-100, 65, 90, 10)];
        lblRestTime.font=[UIFont systemFontOfSize:9];
        lblRestTime.textAlignment=NSTextAlignmentRight;
        lblRestTime.backgroundColor=[UIColor clearColor];
        lblRestTime.textColor=[UIColor lightGrayColor];
        [self.contentView addSubview:lblRestTime];
        self.lblRestTime = lblRestTime;
        
        
        CKDownloadProgress * downloadProgress=[[CKDownloadProgress alloc] initWithFrame:CGRectMake(5, self.frame.size.height-10, SCREEN_WIDTH-10, 10)];
        downloadProgress.autoresizingMask=UIViewAutoresizingFlexibleTopMargin;
        [self.contentView addSubview:downloadProgress];
        self.downloadProgress = downloadProgress;
        
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

-(void) setProgress:(float) progress animated:(BOOL)animated
{
    [self.downloadProgress setProgress:progress animated:animated];
}


@end
