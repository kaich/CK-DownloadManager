//
//  CKInternalAppInstallDownloadCompleteTableViewCell.m
//  Pods
//
//  Created by mac on 15/9/11.
//
//

#import "CKInternalAppInstallDownloadCompleteTableViewCell.h"
#import "UIImage+Color.h"

@implementation CKInternalAppInstallDownloadCompleteTableViewCell

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
        
        
        UILabel * lblDownloadVersion=[[UILabel alloc] initWithFrame:CGRectMake(self.lblTitle.frame.origin.x, 37, 50, 10)];
        lblDownloadVersion.font=[UIFont systemFontOfSize:9];
        lblDownloadVersion.backgroundColor=[UIColor clearColor];
        lblDownloadVersion.textColor=[UIColor blackColor];
        [self.contentView addSubview:lblDownloadVersion];
        self.lblDownloadVersion = lblDownloadVersion;
    }
    return self;
}

+(CGFloat) getHeight
{
    return  80;
}

@end
