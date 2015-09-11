//
//  CKDownloadManagerViewController.m
//  chengkai
//
//  Created by Mac on 14-6-17.
//  Copyright (c) 2014年 chengkai. All rights reserved.
//

#import "CKDownloadManagerViewController.h"
#import "CKDownloadManager.h"
#import "CKBaseDownloadingTableViewCell.h"
#import "CKBaseDownloadCompleteTableViewCell.h"
#import "CKDownloadFileModel.h"
#import "AKSegmentedControl.h"
#import "UIImage+Color.h"
#import "CKLastTouchButton.h"
#import "CKDownloadMacro.h"
#import "UIImageView+WebCache.h"


@interface CKDownloadManagerViewController ()


@end

@implementation CKDownloadManagerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.isEditMode=NO;
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
            [self configDownloadAllButton];
        }
        else
        {
            
        }
    };
    
    mgr.downloadStatusChangedBlock=^(id<CKDownloadModelProtocal> downloadTask ,id target ,BOOL isFiltered){
        
        if(isFiltered)
        {
            CKBaseDownloadingTableViewCell * targetCell=(CKBaseDownloadingTableViewCell *) target;
            
            [self configCell:targetCell downloadModel:(CKDownloadFileModel *)downloadTask];
            
            [self configDownloadAllButton];
            
        }
    };
    
    
    mgr.downloadDeleteExtralBlock=^(id<CKDownloadModelProtocal> model ,NSInteger index ,BOOL isComplete , BOOL isFiltered){
        if(isFiltered)
        {
            [self configDownloadAllButton];
        }
    };
    
    
    
    [self configDownloadAllButton];
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


-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView ==self.tbDownloading)
    {
        return  [CKBaseDownloadingTableViewCell getHeight];
    }
    else
    {
        return  [CKBaseDownloadCompleteTableViewCell getHeight];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView==self.tbDownloading)
    {
        static NSString * CellIdentifier=@"CKDownloadingTableViewCell";
        CKBaseDownloadingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if(!cell)
        {
            Class DownloadingCellClass = [ self downloadingCellClass];
            cell=[[DownloadingCellClass alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
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
        
        [[CKDownloadManager sharedInstance] attachTarget:tableView ProgressBlock:^(id<CKDownloadModelProtocal> downloadTask,CGFloat progress, CGFloat downloadContent, CGFloat totalContent,CGFloat speed,CGFloat restTime, UITableViewCell * theCell) {
            CKBaseDownloadingTableViewCell * downloadCell=(CKBaseDownloadingTableViewCell*)theCell;
            [downloadCell.downloadProgress setProgress:progress animated:YES];
            downloadCell.lblDownloadInfomation.text=[NSString stringWithFormat:@"%.1fMB/%.1fMB(%.2fk/秒)",B_TO_M(downloadContent),B_TO_M(totalContent),B_TO_KB(speed)];
            
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
                [[CKDownloadManager sharedInstance] resumWithURL:[NSURL URLWithString:model.URLString]];
            }
        };
        
        
        cell.deleteBlock=^(CKBaseTableViewCell * theCell){
            NSInteger index=[tableView indexPathForCell:theCell].row;
            CKDownloadBaseModel * model=[[CKDownloadManager sharedInstance].downloadEntities objectAtIndex:index];
            [[CKDownloadManager sharedInstance] deleteWithURL:URL(model.URLString)];
        };
        
        
        [self configEditModeWithCell:cell];
        [self configCell:cell downloadModel:model];
        
        NSString * restTime=[self configShowTime:model.restTime];
        cell.lblRestTime.text=restTime;
        cell.lblDownloadInfomation.text=[NSString stringWithFormat:@"%.1fMB/%.1fMB(%.1fk/秒)",B_TO_M(model.downloadContentSize),B_TO_M(model.totalCotentSize),B_TO_KB(model.speed)];
        [cell.ivImage sd_setImageWithURL:URL(model.imgURLString) placeholderImage:[UIImage imageNamed:@"Placeholder_iPhone"]];
        
        [self customConfigDownloadingCell:cell model:model];
        
        return cell;
    }
    else
    {
        static NSString * CellIdentifier=@"CKDownloadCompleteTableViewCell";
        
        CKBaseDownloadCompleteTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if(!cell)
        {
            Class DownloadCompleteCellClass = [ self downloadCompleteCellClass];
            cell=[[DownloadCompleteCellClass alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        CKDownloadFileModel* model=[[CKDownloadManager sharedInstance].downloadCompleteEntities objectAtIndex:indexPath.row];
        
        cell.clickBlock=^(){
            [self installUrl:URL(model.plistURL) remoteAddress:model.address];
        };
        
        
        cell.deleteBlock=^(CKBaseTableViewCell * theCell){
            NSInteger index=[tableView indexPathForCell:theCell].row;
            CKDownloadBaseModel * model=[[CKDownloadManager sharedInstance].downloadCompleteEntities objectAtIndex:index];
            [[CKDownloadManager sharedInstance] deleteWithURL:URL(model.URLString)];
        };
        
        
        
        [self configEditModeWithCell:cell];
        
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
- (Class) downloadingCellClass
{
    return [CKBaseDownloadingTableViewCell class];
}

- (Class) downloadCompleteCellClass
{
    return [CKBaseDownloadCompleteTableViewCell class];
}

- (void) customConfigDownloadingCell:(CKBaseDownloadingTableViewCell *) downloadingCell model:(id<CKDownloadModelProtocal>) model
{
    
}

- (void) customConfigDownloadCompleteCell:(CKBaseDownloadCompleteTableViewCell *) downloadCompleteCell model:(id<CKDownloadModelProtocal>) model
{
    
}


#pragma mark - UIScrollView Deletate
-(void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if(self.scrollview==scrollView)
    {
        int index=scrollView.contentOffset.x/self.view.frame.size.width;
        [self.segmentControl setSelectedIndex:index];
        
        [self changeEditMode:NO];
    }
}


#pragma mark - observe method
-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"frame"])
    {
        NSValue * rectValue=[change objectForKey:NSKeyValueChangeNewKey];
        CGFloat height=[rectValue CGRectValue].size.height;
        self.scrollview.contentSize=CGSizeMake(self.view.frame.size.width *2,height);
        [self changeFrameOriginX:self.view.frame.size.width view:self.tbDownloadComplete];
        
        if(self.segmentControl.selectedIndexes.firstIndex==0)
        {
            self.scrollview.contentOffset=CGPointMake(0, 0);
        }
        else
        {
            self.scrollview.contentOffset=CGPointMake(self.view.frame.size.width, 0);
        }
    }
}


-(void) changeFrameOriginX:(CGFloat) originX  view:(UIView*) theView
{
    CGRect rect=theView.frame;
    rect.origin.x=originX;
    theView.frame=rect;
}

#pragma mark -  private method 
-(void) installUrl:(NSURL*) url  remoteAddress:(NSString *) address
{
    NSString * name =[url lastPathComponent];
    NSString * pureName=[name stringByDeletingPathExtension];
    NSString * urlStr=[NSString stringWithFormat:@"itms-services://?action=download-manifest&url=%@%@.plist",address,pureName];
    NSURL *plistUrl = [NSURL URLWithString:urlStr];
    [[UIApplication sharedApplication] openURL:plistUrl];
}


-(void) configEditModeWithCell:(CKBaseTableViewCell *) cell
{
   if(self.isEditMode)
   {
       cell.btnDownload.hidden=YES;
       cell.btnDelete.hidden=NO;
   }
   else
   {
    
       cell.btnDownload.hidden=NO;
       cell.btnDelete.hidden=YES;
   }
}

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


#pragma  AKSegment action method
- (void)segmentControlValueChanged:(id)sender
{
    [self changeEditMode:NO];
    
    
    AKSegmentedControl *segmentedControl = (AKSegmentedControl *)sender;
    NSInteger selectedIndex=segmentedControl.selectedIndexes.firstIndex;
    CGPoint contentOffset=CGPointMake(self.scrollview.frame.size.width*selectedIndex, 0);
    [self.scrollview setContentOffset:contentOffset animated:YES];
    
}

#pragma Edit mode
-(IBAction) editDownloadTask:(id) sender
{
    self.isEditMode=!self.isEditMode;
    [self changeEditMode:self.isEditMode];
}

-(void) changeEditMode:(BOOL) isEdit
{

    self.isEditMode=isEdit;
    if(self.isEditMode)
    {
        [self.btnEdit setTitle:@"完成" forState:UIControlStateNormal];
        self.btnAllDownload.hidden=YES;
        self.btnAllDelete.hidden=NO;
        self.btnAllDelete.enabled=YES;
        self.btnAllDelete.alpha=1.f;
    }
    else
    {
        [self.btnEdit setTitle:@"编辑" forState:UIControlStateNormal];
        if(self.segmentControl.selectedIndexes.firstIndex==0)
        {
            self.btnAllDownload.hidden=NO;
            self.btnAllDelete.hidden=YES;
            self.btnAllDelete.enabled=YES;
            self.btnAllDelete.alpha=1.f;
        }
        else
        {
            self.btnAllDownload.hidden=YES;
            self.btnAllDelete.hidden=NO;
            self.btnAllDelete.enabled=NO;
            self.btnAllDelete.alpha=0.5f;
        }
    }
    
    
    [self.tbDownloadComplete reloadData];
    [self.tbDownloading reloadData];
    
}



- (IBAction) deleteAllDownloadTask:(id)sender
{
    if(self.segmentControl.selectedIndexes.firstIndex==0)
    {
        [[CKDownloadManager sharedInstance] deleteAllWithState:YES];
    }
    else
    {
        [[CKDownloadManager sharedInstance] deleteAllWithState:NO];
    }
}


-(void) configDownloadAllButton
{
    if([CKDownloadManager sharedInstance].isHasDownloading)
    {
        [self.btnAllDownload setTitle:@"全部暂停" forState:UIControlStateNormal];
    }
    else
    {
        [self.btnAllDownload setTitle:@"全部开始" forState:UIControlStateNormal];
    }
}



-(void) configCell:(CKBaseDownloadingTableViewCell *) targetCell downloadModel:(CKDownloadFileModel *)  downloadTask
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
