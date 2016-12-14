#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "CKDownHandler.h"
#import "CKDownloadAlertViewProtocol.h"
#import "CKDownloadBaseModel.h"
#import "CKDownloadFilter.h"
#import "CKDownloadManager+MoveDownAndRetry.h"
#import "CKDownloadManager.h"
#import "CKDownloadModelProtocol.h"
#import "CKDownloadPathManager.h"
#import "CKDownloadSpeedAverageQueue.h"
#import "CKHTTPRequestProtocol.h"
#import "CKHTTPRequestQueueProtocol.h"
#import "CKMutableOrdinalDictionary.h"
#import "CKStateCouterManager.h"
#import "CKDownloadFileValidator.h"
#import "CKDownloadRetryController.h"
#import "CKFreeDiskManager.h"
#import "CKRetryModelProtocol.h"
#import "CKValidatorModelProtocol.h"
#import "AFDownloadRequestOperation+Download.h"
#import "NSOperationQueue+Download.h"
#import "CKDownloadFileModel.h"
#import "CKBaseDownloadCompleteTableViewCellProtocol.h"
#import "CKBaseDownloadingTableViewCellProtocol.h"
#import "CKDownloadManager+UITableView.h"
#import "CKDownloadManagerViewController.h"
#import "CKDownloadProgressViewProtocol.h"
#import "CKDownloadTableViewCellProtocol.h"
#import "CKDownloadAlertView.h"
#import "CKDownloadMacro.h"
#import "CKDownloadProgress.h"
#import "CKInternalAppInstallBaseTableViewCell.h"
#import "CKInternalAppInstallDownloadCompleteTableViewCell.h"
#import "CKInternalAppInstallDownloadingTableViewCell.h"
#import "CKInternalAppInstallDownloadManagerViewController.h"
#import "CKLastTouchButton.h"
#import "AKSegmentedControl.h"
#import "UIImage+Color.h"

FOUNDATION_EXPORT double CKDownloadManagerVersionNumber;
FOUNDATION_EXPORT const unsigned char CKDownloadManagerVersionString[];

