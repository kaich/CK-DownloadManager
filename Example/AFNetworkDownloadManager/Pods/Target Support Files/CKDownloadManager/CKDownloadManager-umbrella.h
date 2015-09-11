#import <UIKit/UIKit.h>

#import "CKDownHandler.h"
#import "CKDownloadAlertView.h"
#import "CKDownloadBaseModel.h"
#import "CKDownloadFilter.h"
#import "CKDownloadManager+MoveDownAndRetry.h"
#import "CKDownloadManager+UITableView.h"
#import "CKDownloadManager.h"
#import "CKDownloadModelProtocal.h"
#import "CKDownloadPathManager.h"
#import "CKDownloadSpeedAverageQueue.h"
#import "CKHTTPRequestProtocal.h"
#import "CKHTTPRequestQueueProtocal.h"
#import "CKMutableOrdinalDictionary.h"
#import "CKStateCouterManager.h"
#import "CKDownloadFileValidator.h"
#import "CKDownloadRetryController.h"
#import "CKFreeDiskManager.h"
#import "CKRetryModelProtocal.h"
#import "CKValidatorModelProtocal.h"
#import "AFDownloadRequestOperation+Download.h"
#import "NSOperationQueue+Download.h"
#import "CKDownloadFileModel.h"
#import "CKBaseDownloadCompleteTableViewCell.h"
#import "CKBaseDownloadingTableViewCell.h"
#import "CKBaseTableViewCell.h"
#import "CKDownloadMacro.h"
#import "CKDownloadManagerViewController.h"
#import "CKDownloadProgress.h"
#import "CKDownloadProgressViewDelegate.h"
#import "CKLastTouchButton.h"
#import "CKInternalAppInstallDownloadCompleteTableViewCell.h"
#import "CKInternalAppInstallDownloadingTableViewCell.h"
#import "CKInternalAppInstallDownloadManagerViewController.h"
#import "AKSegmentedControl.h"
#import "UIImage+Color.h"

FOUNDATION_EXPORT double CKDownloadManagerVersionNumber;
FOUNDATION_EXPORT const unsigned char CKDownloadManagerVersionString[];

