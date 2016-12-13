//
//  CKInternalAppInstallDownloadingTableViewCell.m
//  Pods
//
//  Created by mac on 15/9/11.
//
//

#import "CKInternalAppInstallDownloadingTableViewCell.h"
#import "CKDownloadMacro.h"
#import "CKDownloadProgress.h"

@implementation CKInternalAppInstallDownloadingTableViewCell

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


#pragma mark -  class method
+(CGFloat) getHeight
{
    return  93;
}

@end
