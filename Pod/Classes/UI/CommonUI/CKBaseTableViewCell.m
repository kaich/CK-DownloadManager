//
//  CKBaseTableViewCell.m
//  chengkai
//
//  Created by Mac on 14-6-17.
//  Copyright (c) 2014年 chengkai. All rights reserved.
//

#import "CKBaseTableViewCell.h"
#import "CKDownloadMacro.h"

@implementation CKBaseTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        UIImageView * ivImage=[[UIImageView alloc] initWithFrame:CGRectMake(20, 15, 52, 52)];
        ivImage.contentMode=UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:ivImage];
        self.ivImage = ivImage;
        
        
        UILabel * lblTitle=[[UILabel alloc] initWithFrame:CGRectMake(80, 20, SCREEN_WIDTH-160, 14)];
        lblTitle.font=[UIFont systemFontOfSize:13];
        lblTitle.backgroundColor=[UIColor clearColor];
        lblTitle.textColor=[UIColor blackColor];
        [self.contentView addSubview:lblTitle];
        self.lblTitle = lblTitle;
        
        
        UILabel * lblDownloadInfomation=[[UILabel alloc] initWithFrame:CGRectMake(80, 50, SCREEN_WIDTH-160, 10)];
        lblDownloadInfomation.font=[UIFont systemFontOfSize:9];
        lblDownloadInfomation.backgroundColor=[UIColor clearColor];
        lblDownloadInfomation.textColor=[UIColor blackColor];
        [self.contentView addSubview:lblDownloadInfomation];
        self.lblDownloadInfomation = lblDownloadInfomation;
        
        
        UIButton * btnDownload=[UIButton buttonWithType:UIButtonTypeCustom];
        btnDownload.frame=CGRectMake(SCREEN_WIDTH-65,(self.frame.size.height-30)/2, 50, 30);
        [btnDownload setTitle:@"下载" forState:UIControlStateNormal];
        [btnDownload setBackgroundColor:[UIColor blueColor]];
        [btnDownload setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btnDownload.titleLabel.font=[UIFont systemFontOfSize:14];
        btnDownload.autoresizingMask=UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        [btnDownload addTarget:self action:@selector(performDownloadAction) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:btnDownload];
        self.btnDownload = btnDownload;
        
        UIButton * btnDelete=[UIButton buttonWithType:UIButtonTypeCustom];
        btnDelete.frame=CGRectMake(SCREEN_WIDTH-65,(self.frame.size.height-30)/2, 50, 30);
        [btnDelete setTitle:@"删除" forState:UIControlStateNormal];
        [btnDelete setBackgroundColor:[UIColor redColor]];
        [btnDelete setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btnDelete.titleLabel.font=[UIFont systemFontOfSize:14];
        btnDelete.autoresizingMask=UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        [btnDelete addTarget:self action:@selector(performDeleteAction) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:btnDelete];
        self.btnDelete = btnDelete;
        
        self.btnDownload.hidden=NO;
        self.btnDelete.hidden=YES;
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


- (IBAction) performDownloadAction
{
    if(self.clickBlock)
        self.clickBlock();
}

- (IBAction) performDeleteAction
{
    if(self.deleteBlock)
        self.deleteBlock(self);
}


+(CGFloat) getHeight
{
    return 44;
}

@end
