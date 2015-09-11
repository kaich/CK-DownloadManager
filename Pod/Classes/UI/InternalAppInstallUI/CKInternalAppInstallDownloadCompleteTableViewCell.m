//
//  CKInternalAppInstallDownloadCompleteTableViewCell.m
//  Pods
//
//  Created by mac on 15/9/11.
//
//

#import "CKInternalAppInstallDownloadCompleteTableViewCell.h"

@implementation CKInternalAppInstallDownloadCompleteTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
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
