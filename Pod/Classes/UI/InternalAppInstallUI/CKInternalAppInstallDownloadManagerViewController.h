//
//  CKInternalAppInstallDownloadManagerViewController.h
//  Pods
//
//  Created by mac on 15/9/11.
//
//

#import <UIKit/UIKit.h>
#import "CKDownloadManagerViewController.h"
#import "AKSegmentedControl.h"

@interface CKInternalAppInstallDownloadManagerViewController : CKDownloadManagerViewController
@property(nonatomic,weak) IBOutlet AKSegmentedControl * segmentControl;
@end
