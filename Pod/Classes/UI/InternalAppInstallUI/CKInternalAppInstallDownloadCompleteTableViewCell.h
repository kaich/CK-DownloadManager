//
//  CKInternalAppInstallDownloadCompleteTableViewCell.h
//  Pods
//
//  Created by mac on 15/9/11.
//
//

#import <UIKit/UIKit.h>
#import "CKBaseDownloadCompleteTableViewCellProtocol.h"
#import "CKInternalAppInstallBaseTableViewCell.h"

@interface CKInternalAppInstallDownloadCompleteTableViewCell : CKInternalAppInstallBaseTableViewCell<CKBaseDownloadCompleteTableViewCellProtocol>

@property(nonatomic,weak) IBOutlet UILabel * lblDownloadVersion;
@end
