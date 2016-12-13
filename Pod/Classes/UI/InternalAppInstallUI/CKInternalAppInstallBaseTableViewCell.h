//
//  CKInternalAppInstallBaseTableViewCell.h
//  Pods
//
//  Created by mac on 16/11/29.
//
//

#import <UIKit/UIKit.h>
#import "CKDownloadTableViewCellProtocol.h"

@interface CKInternalAppInstallBaseTableViewCell : UITableViewCell<CKDownloadTableViewCellProtocol>
//image view
@property(nonatomic,weak) IBOutlet UIImageView * ivImage;
//title
@property(nonatomic,weak) IBOutlet UILabel * lblTitle;
//downloadng is speed , paused is totalReadSize/TotalSize
@property(nonatomic,weak) IBOutlet UILabel * lblDownloadInfomation;
//button for download and pause
@property(nonatomic,weak) IBOutlet UIButton * btnDownload;
//delete button
@property(nonatomic,weak) IBOutlet UIButton * btnDelete;

//btnDownload click action
- (IBAction) performDownloadAction;
//btnDelete click action
- (IBAction) performDeleteAction;

//click action block for btnDownload
@property(nonatomic,copy) ClickBlock  clickBlock;
//click action block for btnDelete
@property(nonatomic,copy) DeleteBlock  deleteBlock;

+(CGFloat) getHeight;
@end
