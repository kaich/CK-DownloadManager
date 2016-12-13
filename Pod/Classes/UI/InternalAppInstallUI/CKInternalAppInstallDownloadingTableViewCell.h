//
//  CKInternalAppInstallDownloadingTableViewCell.h
//  Pods
//
//  Created by mac on 15/9/11.
//
//

#import <UIKit/UIKit.h>
#import "CKBaseDownloadingTableViewCellProtocol.h"
#import "CKInternalAppInstallBaseTableViewCell.h"

@interface CKInternalAppInstallDownloadingTableViewCell : CKInternalAppInstallBaseTableViewCell<CKBaseDownloadingTableViewCellProtocol>

//task download progress
@property(nonatomic,weak) IBOutlet id<CKDownloadProgressViewProtocol>  downloadProgress;
//task status , downloading , pasue , wait and so on
@property(nonatomic,weak) IBOutlet UILabel * lblDownloadStatus;
//download rest time
@property(nonatomic,weak) IBOutlet UILabel * lblRestTime;

@end
