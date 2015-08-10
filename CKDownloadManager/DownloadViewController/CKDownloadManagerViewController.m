//
//  CKDownloadManagerViewController.m
//  aisiweb
//
//  Created by Mac on 14-6-17.
//  Copyright (c) 2014年 weiaipu. All rights reserved.
//

#import "CKDownloadManagerViewController.h"
#import "CKDownloadManager.h"
#import "CKDownloadingTableViewCell.h"
#import "CKDownloadFinishedTableViewCell.h"
#import "CKDownloadManager+UITableView.h"
#import "CKDownloadPlistFactory.h"
#import "CKDownloadFileModel.h"
#import "AKSegmentedControl.h"
#import "UIImage+Color.h"
#import "CKDownloadManager+RefrenceItem.h"
#import "CKLastTouchButton.h"
#import "CKDownloadMacro.h"
#import "UIImageView+WebCache.h"




@interface CKDownloadManagerViewController ()<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,strong) UIView * vwHeader;
@property(nonatomic,strong) UIButton * btnEdit;
@property(nonatomic,strong) UIButton * btnAllDelete;
@property(nonatomic,strong) CKLastTouchButton * btnAllDownload;
@property(nonatomic,strong) UITableView * tbDownloading;
@property(nonatomic,strong) UITableView * tbDownloadComplete;
@property(nonatomic,strong) UIScrollView * scrollview;
@property(nonatomic,strong) AKSegmentedControl * segmentControl;


@property(nonatomic,assign) BOOL tapState;  // YES  all downloading   NO  pause
@property(nonatomic,assign) BOOL isEditMode;
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

-(void) loadView
{
    [super loadView];
    
    //1.header
    self.vwHeader=[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 80)];
    self.vwHeader.autoresizingMask=UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.vwHeader];
    
    //2.scrollview
    CGFloat originY=self.vwHeader.frame.origin.y+self.vwHeader.frame.size.height;
    self.scrollview=[[UIScrollView alloc] initWithFrame:CGRectMake(0, originY, self.view.frame.size.width,self.view.frame.size.height-originY)];
    self.scrollview.contentSize=CGSizeMake(self.view.frame.size.width*2, self.scrollview.frame.size.height);
    self.scrollview.pagingEnabled=YES;
    self.scrollview.showsHorizontalScrollIndicator=NO;
    self.scrollview.showsVerticalScrollIndicator=NO;
    self.scrollview.delegate=self;
    self.scrollview.autoresizingMask=UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.scrollview];
    
    //3. donwloading table
    self.tbDownloading=[[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.scrollview.frame.size.height) style:UITableViewStylePlain];
    self.tbDownloading.delegate=self;
    self.tbDownloading.dataSource=self;
    self.tbDownloading.separatorStyle=UITableViewCellSeparatorStyleNone;
    self.tbDownloading.autoresizingMask=UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.tbDownloading.allowsSelection=NO;
    [self.scrollview addSubview:self.tbDownloading];
    
    //4.download complete table
    self.tbDownloadComplete=[[UITableView alloc] initWithFrame:CGRectMake(self.view.frame.size.width, 0, self.view.frame.size.width, self.scrollview.frame.size.height) style:UITableViewStylePlain];
    self.tbDownloadComplete.delegate=self;
    self.tbDownloadComplete.dataSource=self;
    self.tbDownloadComplete.separatorStyle=UITableViewCellSeparatorStyleNone;
    self.tbDownloadComplete.autoresizingMask=UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.tbDownloadComplete.allowsSelection=NO;
    [self.scrollview addSubview:self.tbDownloadComplete];
    
    [self configHeaderView];
    
    [self.scrollview addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    CKDownloadManager * mgr =[CKDownloadManager sharedInstance];
    

    [mgr setDownloadingTable:self.tbDownloading completeTable:self.tbDownloadComplete];
    mgr.downloadCompleteExtralBlock=^(CKDownloadBaseModel * model , NSInteger exutingIndex,NSInteger completeIndex ,BOOL isFiltered){
        if(isFiltered)
        {
            [self configDownloadAll];
        }
        else
        {
            if([model.URLString rangeOfString:@"plist"].location!=NSNotFound)
            {
                CKDownloadFileModel * fileModel=(CKDownloadFileModel*) model;
                [CKDownloadPlistFactory createPlistWithURL:URL(fileModel.URLString) iconImageURL:URL(fileModel.imgURLString) appURL:URL(fileModel.appURL) baseURL:fileModel.address];
            }
        }
    };
    
    mgr.downloadStatusChangedBlock=^(id<CKDownloadModelProtocal> downloadTask ,id target ,BOOL isFiltered){
        
        if(isFiltered)
        {
            CKDownloadingTableViewCell * targetCell=(CKDownloadingTableViewCell *) target;

            [self configCell:targetCell downloadModel:(CKDownloadFileModel *)downloadTask];
            
            [self configDownloadAll];
            
        }
    };
    

    mgr.downloadDeleteExtralBlock=^(id<CKDownloadModelProtocal> model ,NSInteger index ,BOOL isComplete , BOOL isFiltered){
        if(isFiltered)
        {
            [self configDownloadAll];
        }
    };
    
    
    
    [self configDownloadAll];
    
    self.tapState=mgr.isAllDownloading;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - config UI
- (void)setupSegmentedControl
{
    self.segmentControl=[[AKSegmentedControl alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,40)];
    [self.segmentControl setBackgroundColor:HexRGBAlpha(0x236ee7, 0.95)];
    [self.segmentControl setContentEdgeInsets:UIEdgeInsetsMake(2.0, 2.0, 3.0, 2.0)];
    [self.segmentControl setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin];
    self.segmentControl.segmentedControlMode=AKSegmentedControlModeSticky;
    [self.segmentControl setSeparatorImage:[UIImage imageNamed:@""]];
    

    
    // Button 1
    
    UIButton *buttonDownloading = [[UIButton alloc] init];
    CGSize size=CGSizeMake(self.view.frame.size.width/2, 40);
    CGRect contentRect=CGRectMake((size.width-80)/2, 3, 80, 34);
    UIImage *imgN =nil;
    UIImage *imgH = [UIImage imageWithColor:HexRGBAlpha(0x1e62cb, 1) andSize:size contentRect:contentRect  cornerRadius:5];
    
    
    UIColor * normalColor=[UIColor whiteColor];
    UIColor * highlightColor=[UIColor whiteColor];
    
    [buttonDownloading setImageEdgeInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 5.0)];
    [buttonDownloading setBackgroundImage:imgN forState:UIControlStateNormal];
    [buttonDownloading setBackgroundImage:imgH forState:UIControlStateSelected];
    [buttonDownloading setBackgroundImage:imgH forState:UIControlStateHighlighted];
    [buttonDownloading setBackgroundImage:imgH forState:(UIControlStateHighlighted|UIControlStateSelected)];
    [buttonDownloading setTitle:@"下载中" forState:UIControlStateNormal];
    [buttonDownloading setTitleColor:normalColor forState:UIControlStateNormal];
    [buttonDownloading setTitleColor:highlightColor forState:UIControlStateHighlighted];
    [buttonDownloading setTitleColor:highlightColor forState:UIControlStateSelected];
    buttonDownloading.titleLabel.font=[UIFont systemFontOfSize:15];
    
    // Button 2
    UIButton *buttonDownloadFinished = [[UIButton alloc] init];
    [buttonDownloadFinished setBackgroundImage:imgN forState:UIControlStateNormal];
    [buttonDownloadFinished setBackgroundImage:imgH forState:UIControlStateSelected];
    [buttonDownloadFinished setBackgroundImage:imgH forState:UIControlStateHighlighted];
    [buttonDownloadFinished setBackgroundImage:imgH forState:(UIControlStateHighlighted|UIControlStateSelected)];
    [buttonDownloadFinished setTitle:@"已下载" forState:UIControlStateNormal];
    [buttonDownloadFinished setTitleColor:normalColor forState:UIControlStateNormal];
    [buttonDownloadFinished setTitleColor:highlightColor forState:UIControlStateHighlighted];
    [buttonDownloadFinished setTitleColor:highlightColor forState:UIControlStateSelected];
    buttonDownloadFinished.titleLabel.font=[UIFont systemFontOfSize:15];

    
    [self.segmentControl setButtonsArray:@[buttonDownloading, buttonDownloadFinished]];
    [self.segmentControl addTarget:self action:@selector(segmentedViewController:) forControlEvents:UIControlEventValueChanged];
    [self.segmentControl setSelectedIndex:0];
    [self.vwHeader addSubview:self.segmentControl];
}


-(void) configHeaderView
{
    [self setupSegmentedControl];
    
    self.btnEdit=[UIButton buttonWithType:UIButtonTypeCustom];
    self.btnEdit.frame=CGRectMake(self.vwHeader.frame.size.width-150,45, 50, 30);
    [self.btnEdit setTitle:@"编辑" forState:UIControlStateNormal];
    [self.btnEdit setBackgroundColor:[UIColor blueColor]];
    [self.btnEdit setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.btnEdit.titleLabel.font=[UIFont systemFontOfSize:14];
    self.btnEdit.autoresizingMask=UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
    [self.btnEdit addTarget:self action:@selector(editDownloadTask) forControlEvents:UIControlEventTouchUpInside];
    [self.vwHeader addSubview:self.btnEdit];
    
    self.btnAllDelete=[UIButton buttonWithType:UIButtonTypeCustom];
    self.btnAllDelete.frame=CGRectMake(self.vwHeader.frame.size.width-90,45, 80, 30);
    [self.btnAllDelete setTitle:@"全部删除" forState:UIControlStateNormal];
    [self.btnAllDelete setBackgroundColor:[UIColor blueColor]];
    [self.btnAllDelete setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.btnAllDelete.titleLabel.font=[UIFont systemFontOfSize:14];
    self.btnAllDelete.autoresizingMask=UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
    [self.btnAllDelete addTarget:self action:@selector(deleteAllDownloadTask) forControlEvents:UIControlEventTouchUpInside];
    self.btnAllDownload.hidden=YES;
    [self.vwHeader addSubview:self.btnAllDelete];
    
    self.btnAllDownload=[[CKLastTouchButton alloc] init];
    self.btnAllDownload.frame=CGRectMake(self.vwHeader.frame.size.width-90,45, 80, 30);
    [self.btnAllDownload setTitle:@"全部开始" forState:UIControlStateNormal];
    [self.btnAllDownload setBackgroundColor:[UIColor blueColor]];
    [self.btnAllDownload setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.btnAllDownload.titleLabel.font=[UIFont systemFontOfSize:14];
    self.btnAllDownload.autoresizingMask=UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
    [self.vwHeader addSubview:self.btnAllDownload];
    
    
    //every time touch change the word of button, but not work any function ,when the last touch, the button function.
    __weak typeof(self)weakSelf = self;
    [self.btnAllDownload setTouchUpInsideEveryTimeActionBlock:^(UIButton *sender) {
        [weakSelf configDownloadAllWithTapState];
    } finalAcitonBlock:^(UIButton *sender) {
        if(weakSelf.tapState)
        {
            [[CKDownloadManager sharedInstance] startAllWithCancelBlock:^{
                
            }];
        }
        else
        {
             [[CKDownloadManager sharedInstance] pauseAll];
        }
    }];
    
    [self configDownloadAll];
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
        return  [CKDownloadingTableViewCell getHeight];
    }
    else
    {
        return  [CKDownloadFinishedTableViewCell getHeight];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView==self.tbDownloading)
    {
        static NSString * CellIdentifier=@"CKDownloadingTableViewCell";
        CKDownloadingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if(!cell)
        {
            cell=[[CKDownloadingTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        CKDownloadFileModel * model=[[CKDownloadManager sharedInstance].downloadEntities objectAtIndex:indexPath.row];
        if(model.downloadContentSize>0 && model.totalCotentSize >0)
        {
            [cell setProgress:((CGFloat)model.downloadContentSize/(CGFloat)model.totalCotentSize)  animated:NO];
        }
        else
        {
            [cell setProgress:0 animated:NO];
        }
        
        cell.lblTitle.text=model.title;
        
        [[CKDownloadManager sharedInstance] attachTarget:tableView ProgressBlock:^(id<CKDownloadModelProtocal> downloadTask,CGFloat progress, CGFloat downloadContent, CGFloat totalContent,CGFloat speed,CGFloat restTime, UITableViewCell * theCell) {
            CKDownloadingTableViewCell * downloadCell=(CKDownloadingTableViewCell*)theCell;
            [downloadCell setProgress:progress animated:YES];
            downloadCell.lblDownloadInfo.text=[NSString stringWithFormat:@"%.1fMB/%.1fMB(%.2fk/秒)",B_TO_M(downloadContent),B_TO_M(totalContent),B_TO_KB(speed)];
            
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
        cell.lblDownloadInfo.text=[NSString stringWithFormat:@"%.1fMB/%.1fMB(%.1fk/秒)",B_TO_M(model.downloadContentSize),B_TO_M(model.totalCotentSize),B_TO_KB(model.speed)];
        cell.lblDownloadVersion.text=[NSString stringWithFormat:@"版本:%@",model.fileVersion];
        [cell.ivImage sd_setImageWithURL:URL(model.imgURLString) placeholderImage:[UIImage imageNamed:@"Placeholder_iPhone"]];
        
        
        return cell;
    }
    else
    {
        static NSString * CellIdentifier=@"CKDownloadFinishTableViewCell";
        CKDownloadFinishedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if(!cell)
        {
            cell=[[CKDownloadFinishedTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
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
        cell.lblDownloadInfo.text=[NSString stringWithFormat:@"版本%@|%.1fM|%@",model.fileVersion,B_TO_M(model.totalCotentSize) ,model.downloadDate];
        [cell.ivImage sd_setImageWithURL:URL(model.imgURLString) placeholderImage:[UIImage imageNamed:@"Placeholder_iPhone"]];
        
        return  cell;
    }
}


-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
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
- (void)segmentedViewController:(id)sender
{
    [self changeEditMode:NO];
    
    
    AKSegmentedControl *segmentedControl = (AKSegmentedControl *)sender;
    NSInteger selectedIndex=segmentedControl.selectedIndexes.firstIndex;
    CGPoint contentOffset=CGPointMake(self.view.frame.size.width*selectedIndex, 0);
    [self.scrollview setContentOffset:contentOffset animated:YES];
    
    
}

#pragma Edit mode 
-(void) editDownloadTask
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



-(void) deleteAllDownloadTask
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


-(void) configDownloadAll
{
    if([CKDownloadManager sharedInstance].isHasDownloading)
    {
        [self.btnAllDownload setTitle:@"全部暂停" forState:UIControlStateNormal];
    }
    else
    {
        [self.btnAllDownload setTitle:@"全部开始" forState:UIControlStateNormal];
    }
    
    self.tapState=[CKDownloadManager sharedInstance].isAllDownloading;
}


-(void) configDownloadAllWithTapState
{
    self.tapState=!self.tapState;
    if(self.tapState)
    {
        [self.btnAllDownload setTitle:@"全部暂停" forState:UIControlStateNormal];
    }
    else
    {
        [self.btnAllDownload setTitle:@"全部开始" forState:UIControlStateNormal];
    }
}


-(void) configCell:(CKDownloadingTableViewCell *) targetCell downloadModel:(CKDownloadFileModel *)  downloadTask
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
