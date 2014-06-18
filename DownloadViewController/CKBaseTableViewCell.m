//
//  CKBaseTableViewCell.m
//  aisiweb
//
//  Created by Mac on 14-6-17.
//  Copyright (c) 2014年 weiaipu. All rights reserved.
//

#import "CKBaseTableViewCell.h"

@implementation CKBaseTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        self.ivImage=[[UIImageView alloc] initWithFrame:CGRectMake(20, 20, 52, 52)];
        self.ivImage.contentMode=UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:self.ivImage];
        
        self.lblTitle=[[UILabel alloc] initWithFrame:CGRectMake(80, 25, SCREEN_WIDTH-160, 14)];
        self.lblTitle.font=[UIFont systemFontOfSize:13];
        self.lblTitle.backgroundColor=[UIColor clearColor];
        self.lblTitle.textColor=[UIColor blackColor];
        [self.contentView addSubview:self.lblTitle];

        
        self.lblDownloadInfo=[[UILabel alloc] initWithFrame:CGRectMake(80, 55, SCREEN_WIDTH-160, 10)];
        self.lblDownloadInfo.font=[UIFont systemFontOfSize:9];
        self.lblDownloadInfo.backgroundColor=[UIColor clearColor];
        self.lblDownloadInfo.textColor=[UIColor blackColor];
        [self.contentView addSubview:self.lblDownloadInfo];
        
        
        self.btnDownload=[UIButton buttonWithType:UIButtonTypeCustom];
        self.btnDownload.frame=CGRectMake(SCREEN_WIDTH-65,(self.frame.size.height-30)/2, 50, 30);
        [self.btnDownload setTitle:@"下载" forState:UIControlStateNormal];
        [self.btnDownload setBackgroundColor:[UIColor blueColor]];
        [self.btnDownload setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.btnDownload.titleLabel.font=[UIFont systemFontOfSize:14];
        self.btnDownload.autoresizingMask=UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        [self.btnDownload addTarget:self action:@selector(performButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.btnDownload];
        
        self.btnDelete=[UIButton buttonWithType:UIButtonTypeCustom];
        self.btnDelete.frame=CGRectMake(SCREEN_WIDTH-65,(self.frame.size.height-30)/2, 50, 30);
        [self.btnDelete setTitle:@"删除" forState:UIControlStateNormal];
        [self.btnDelete setBackgroundColor:[UIColor redColor]];
        [self.btnDelete setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.btnDelete.titleLabel.font=[UIFont systemFontOfSize:14];
        self.btnDelete.autoresizingMask=UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        [self.btnDelete addTarget:self action:@selector(performDeleteButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.btnDelete];
        
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


- (IBAction) performButtonAction
{
    if(self.clickBlock)
        self.clickBlock();
}

-(void)performDeleteButtonAction
{
    if(self.deleteBlock)
        self.deleteBlock(self);
}

@end
