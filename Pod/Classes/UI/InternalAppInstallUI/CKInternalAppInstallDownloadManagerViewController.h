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
@property(nonatomic,assign) BOOL isEditMode;

@property(nonatomic,weak) IBOutlet UIScrollView * scrollview;
@property(nonatomic,weak) IBOutlet AKSegmentedControl * segmentControl;


@property(nonatomic,weak) IBOutlet UIButton * btnEdit;
@property(nonatomic,weak) IBOutlet UIButton * btnAllDelete;

- (IBAction) segmentControlValueChanged:(id)sender;
- (IBAction) editDownloadTask:(id) sender;
- (IBAction) deleteAllDownloadTask:(id) sender;
@end
