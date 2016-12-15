//
//  CKDownloadManagerViewController.m
//  chengkai
//
//  Created by Mac on 14-6-17.
//  Copyright (c) 2014年 chengkai. All rights reserved.
//

#import "CKDownloadManagerViewController.h"
#import "CKDownloadManager.h"
#import "CKDownloadFileModel.h"
#import "UIImageView+WebCache.h"
#import "NSString+Download.h"


@implementation CKDownloadManagerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self configDownloadManager];
}

-(void) configDownloadManager
{
    CKDownloadManager * mgr =[CKDownloadManager sharedInstance];
    
    
    mgr.downloadCompleteExtralBlock=^(CKDownloadBaseModel * model , NSInteger exutingIndex,NSInteger completeIndex ,BOOL isFiltered){
        if(isFiltered)
        {
            [self downloadChanged];
        }
        else
        {
            
        }
    };
    
    mgr.downloadStatusChangedBlock=^(id<CKDownloadModelProtocol> downloadTask ,id target ,BOOL isFiltered){
        
        if(isFiltered)
        {
            CKBaseDownloadingTableViewCell * targetCell=(CKBaseDownloadingTableViewCell *) target;
            
            [self configCell:targetCell downloadModel:(CKDownloadFileModel *)downloadTask];
            
            [self downloadChanged];
            
        }
    };
    
    
    mgr.downloadDeleteExtralBlock=^(id<CKDownloadModelProtocol> model ,NSInteger index ,BOOL isComplete , BOOL isFiltered){
        if(isFiltered)
        {
            [self downloadChanged];
        }
    };
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView==self.tbDownloading) {
        return [CKDownloadManager sharedInstance].downloadEntities.count;
    }
    else
    {
        return [CKDownloadManager sharedInstance].downloadCompleteEntities.count;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView==self.tbDownloading)
    {
        UITableViewCell<CKBaseDownloadingTableViewCellProtocol> *cell = [tableView dequeueReusableCellWithIdentifier:DownloadingCellIdentifier forIndexPath:indexPath];
        CKDownloadFileModel * model=[[CKDownloadManager sharedInstance].downloadEntities objectAtIndex:indexPath.row];
        if(model.downloadContentSize>0 && model.totalCotentSize >0)
        {
            [cell.downloadProgress setProgress:((CGFloat)model.downloadContentSize/(CGFloat)model.totalCotentSize)  animated:NO];
        }
        else
        {
            [cell.downloadProgress setProgress:0 animated:NO];
        }
        
        cell.lblTitle.text=model.title;
        
        [[CKDownloadManager sharedInstance] attachTarget:tableView ProgressBlock:^(id<CKDownloadModelProtocol> downloadTask,CGFloat progress, CGFloat downloadContent, CGFloat totalContent,CGFloat speed,CGFloat restTime, UITableViewCell * theCell) {
            
            UITableViewCell<CKBaseDownloadingTableViewCellProtocol> * downloadCell=(UITableViewCell<CKBaseDownloadingTableViewCellProtocol>*)theCell;
            [downloadCell.downloadProgress setProgress:progress animated:NO];
            downloadCell.lblDownloadInfomation.text=[NSString stringWithFormat:@"%.1fMB/%.1fMB(%@/秒)",B_TO_M(downloadContent),B_TO_M(totalContent),[NSString ck_fileSize:model.speed]];
            
            NSString * restTimeStr=[self configShowTime:restTime];
            downloadCell.lblRestTime.text=restTimeStr;

        } URL:URL(model.URLString)];
        
        
        cell.clickBlock=^(){
            if(model.downloadState == kDSWaitDownload || model.downloadState == kDSDownloading)
            {
                [[CKDownloadManager sharedInstance] pauseWithURL:[NSURL URLWithString:model.URLString]];
            }
            else
            {
                [[CKDownloadManager sharedInstance] resumeWithURL:[NSURL URLWithString:model.URLString]];
            }
        };
        
        
        cell.deleteBlock=^(UITableViewCell<CKBaseDownloadingTableViewCellProtocol> * theCell){
            NSInteger index=[tableView indexPathForCell:theCell].row;
            CKDownloadBaseModel * model=[[CKDownloadManager sharedInstance].downloadEntities objectAtIndex:index];
            [[CKDownloadManager sharedInstance] deleteWithURL:URL(model.URLString)];
        };
        
        [self configCell:cell downloadModel:model];
        
        if(model.downloadState == kDSDownloading) {
            cell.lblRestTime.hidden = NO;
        }
        else {
            cell.lblRestTime.hidden = YES;
        }
        NSString * restTime=[self configShowTime:model.restTime];
        cell.lblRestTime.text=restTime;
        cell.lblDownloadInfomation.text=[NSString stringWithFormat:@"%.1fMB/%.1fMB(%@/秒)",B_TO_M(model.downloadContentSize),B_TO_M(model.totalCotentSize),[NSString ck_fileSize:model.speed]];
        [cell.ivImage sd_setImageWithURL:URL(model.imgURLString) placeholderImage:[UIImage imageNamed:@"Placeholder_iPhone"]];
        
        [self customConfigDownloadingCell:cell model:model];
        
        return cell;
    }
    else
    {
        
        UITableViewCell<CKBaseDownloadCompleteTableViewCellProtocol> *cell = [tableView dequeueReusableCellWithIdentifier:DownloadCompleteCellIdentifier forIndexPath:indexPath];
        
        CKDownloadFileModel* model=[[CKDownloadManager sharedInstance].downloadCompleteEntities objectAtIndex:indexPath.row];
        
        cell.clickBlock=^(){
            [self clickCompleteButton:model];
        };
        
        
        cell.deleteBlock=^(UITableViewCell<CKBaseDownloadCompleteTableViewCellProtocol> * theCell){
            NSInteger index=[tableView indexPathForCell:theCell].row;
            CKDownloadBaseModel * model=[[CKDownloadManager sharedInstance].downloadCompleteEntities objectAtIndex:index];
            [[CKDownloadManager sharedInstance] deleteWithURL:URL(model.URLString)];
        };
        
        
        cell.lblTitle.text=model.title;
        [cell.ivImage sd_setImageWithURL:URL(model.imgURLString) placeholderImage:[UIImage imageNamed:@"Placeholder_iPhone"]];
        
        [self customConfigDownloadCompleteCell:cell model:model];
        
        return  cell;
    }
}


-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}


#pragma mark - override method
- (void) downloadChanged
{
    
}

- (void) customConfigDownloadingCell:(CKBaseDownloadingTableViewCell *) downloadingCell model:(id<CKDownloadModelProtocol>) model
{
    
}


- (void) customConfigDownloadCompleteCell:(CKBaseDownloadCompleteTableViewCell *) downloadCompleteCell model:(id<CKDownloadModelProtocol>) model
{
    
}

-(void) clickCompleteButton:(id<CKDownloadModelProtocol>) model {
    
}

#pragma mark -  private method 
-(NSString *) configShowTime:(NSTimeInterval) seconds
{
    if(seconds/(60*60*24)> 1)
    {
        return  @"剩余:大于1天";
    }
    else
    {
        int  theHour=seconds/3600;
        int  theMunite=(seconds-theHour*3600)/60;
        int  theSecond=seconds-theHour*3600-theMunite*60;
        
        NSString * result =[NSString stringWithFormat:@"剩余:%.2d小时%.2d分%.2d秒",theHour,theMunite,theSecond];
        return result;
    }
    
}


-(void) configCell:(id<CKBaseDownloadingTableViewCellProtocol>) targetCell downloadModel:(id<CKDownloadModelProtocol>)  downloadTask
{
    if(targetCell)
    {
        if(downloadTask.downloadState==kDSDownloadPause)
        {
            [targetCell.btnDownload setTitle:@"下载" forState:UIControlStateNormal];
            targetCell.lblDownloadStatus.text=@"暂停下载";
            
        }
        else if(downloadTask.downloadState==kDSDownloading)
        {
            [targetCell.btnDownload setTitle:@"暂停" forState:UIControlStateNormal];
            targetCell.lblDownloadStatus.text=@"正在下载";
        }
        else if(downloadTask.downloadState==kDSWaitDownload)
        {
            [targetCell.btnDownload setTitle:@"暂停" forState:UIControlStateNormal];
            targetCell.lblDownloadStatus.text=@"等待下载";
        }
    }
}

@end
