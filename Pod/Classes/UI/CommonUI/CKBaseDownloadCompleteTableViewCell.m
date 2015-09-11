//
//  CKDownloadFinishedTableViewCell.m
//  chengkai
//
//  Created by Mac on 14-6-17.
//  Copyright (c) 2014年 chengkai. All rights reserved.
//

#import "CKBaseDownloadCompleteTableViewCell.h"
#import "UIImage+Color.h"

@implementation CKBaseDownloadCompleteTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        [self.btnDownload setTitle:@"安装" forState:UIControlStateNormal];
        
        
        UIImageView * ivLine=[[UIImageView alloc] initWithFrame:CGRectMake(5, self.frame.size.height-1, self.frame.size.width-10, 1)];
        ivLine.image=[UIImage lineImageWithSize:CGSizeMake(self.frame.size.width-10, 0.5) color:[UIColor grayColor]];
        ivLine.contentMode=UIViewContentModeCenter;
        ivLine.alpha=0.5;
        ivLine.autoresizingMask=UIViewAutoresizingFlexibleTopMargin;
        [self.contentView addSubview:ivLine];
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


@end
