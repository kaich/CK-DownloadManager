//
//  CKInternalAppInstallDownloadManagerViewController.m
//  Pods
//
//  Created by mac on 15/9/11.
//
//

#import "CKInternalAppInstallDownloadManagerViewController.h"
#import "UIImage+Color.h"
#import "CKDownloadMacro.h"
#import "CKLastTouchButton.h"
#import "CKDownloadManager.h"
#import "CKInternalAppInstallDownloadCompleteTableViewCell.h"
#import "CKInternalAppInstallDownloadingTableViewCell.h"
#import "CKDownloadFileModel.h"
#import "CKLastTouchButton.h"


@interface CKInternalAppInstallDownloadManagerViewController ()
@property(nonatomic,strong) UIView * vwHeader;
@property(nonatomic,weak) IBOutlet CKLastTouchButton * btnAllDownload;
@property(nonatomic,assign) BOOL tapState;  // YES  has downloading   NO all pause
@end

@implementation CKInternalAppInstallDownloadManagerViewController
@synthesize segmentControl = _segmentControl;
@synthesize btnAllDownload = _btnAllDownload;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.isEditMode=NO;
    
    //1.header
    self.vwHeader=[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 80)];
    self.vwHeader.autoresizingMask=UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.vwHeader];
    
    //2.scrollview
    CGFloat originY=self.vwHeader.frame.origin.y+self.vwHeader.frame.size.height;
    UIScrollView * scrollview=[[UIScrollView alloc] initWithFrame:CGRectMake(0, originY, self.view.frame.size.width,self.view.frame.size.height-originY)];
    scrollview.contentSize=CGSizeMake(self.view.frame.size.width*2, scrollview.frame.size.height);
    scrollview.pagingEnabled=YES;
    scrollview.showsHorizontalScrollIndicator=NO;
    scrollview.showsVerticalScrollIndicator=NO;
    scrollview.delegate=self;
    scrollview.autoresizingMask=UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:scrollview];
    self.scrollview = scrollview;
    
    
    //3. donwloading table
    UITableView * tbDownloading=[[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.scrollview.frame.size.height) style:UITableViewStylePlain];
    tbDownloading.delegate=self;
    tbDownloading.dataSource=self;
    tbDownloading.separatorStyle=UITableViewCellSeparatorStyleNone;
    tbDownloading.autoresizingMask=UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    tbDownloading.allowsSelection=NO;
    [self.scrollview addSubview:tbDownloading];
    self.tbDownloading = tbDownloading;
    
    //4.download complete table
    UITableView * tbDownloadComplete=[[UITableView alloc] initWithFrame:CGRectMake(self.view.frame.size.width, 0, self.view.frame.size.width, self.scrollview.frame.size.height) style:UITableViewStylePlain];
    tbDownloadComplete.delegate=self;
    tbDownloadComplete.dataSource=self;
    tbDownloadComplete.separatorStyle=UITableViewCellSeparatorStyleNone;
    tbDownloadComplete.autoresizingMask=UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    tbDownloadComplete.allowsSelection=NO;
    [self.scrollview addSubview:tbDownloadComplete];
    self.tbDownloadComplete = tbDownloadComplete;
    
    [self configHeaderView];
    
    self.tapState=[CKDownloadManager sharedInstance].isHasDownloading;
    [self.scrollview addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
    
    [self configDownloadAllButton];
    
    [tbDownloading registerClass:[CKInternalAppInstallDownloadingTableViewCell class] forCellReuseIdentifier: DownloadingCellIdentifier];
    [tbDownloadComplete registerClass:[CKInternalAppInstallDownloadCompleteTableViewCell class] forCellReuseIdentifier: DownloadCompleteCellIdentifier];
    
    [[CKDownloadManager sharedInstance] setDownloadingTable:self.tbDownloading completeTable:self.tbDownloadComplete];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark - config UI
- (void)setupSegmentedControl
{
    AKSegmentedControl * segmentControl=[[AKSegmentedControl alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,40)];
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
    
    
    [segmentControl setButtonsArray:@[buttonDownloading, buttonDownloadFinished]];
    [segmentControl addTarget:self action:@selector(segmentControlValueChanged:) forControlEvents:UIControlEventValueChanged];
    [segmentControl setSelectedIndex:0];
    [self.vwHeader addSubview:segmentControl];
    self.segmentControl = segmentControl;
}

-(void) configHeaderView
{
    [self setupSegmentedControl];
    
    UIButton * btnEdit=[UIButton buttonWithType:UIButtonTypeCustom];
    btnEdit.frame=CGRectMake(self.vwHeader.frame.size.width-150,45, 50, 30);
    [btnEdit setTitle:@"编辑" forState:UIControlStateNormal];
    [btnEdit setBackgroundColor:[UIColor blueColor]];
    [btnEdit setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnEdit.titleLabel.font=[UIFont systemFontOfSize:14];
    btnEdit.autoresizingMask=UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
    [btnEdit addTarget:self action:@selector(editDownloadTask:) forControlEvents:UIControlEventTouchUpInside];
    [self.vwHeader addSubview:btnEdit];
    self.btnEdit = btnEdit;
    
    
    UIButton * btnAllDelete=[UIButton buttonWithType:UIButtonTypeCustom];
    btnAllDelete.frame=CGRectMake(self.vwHeader.frame.size.width-90,45, 80, 30);
    [btnAllDelete setTitle:@"全部删除" forState:UIControlStateNormal];
    [btnAllDelete setBackgroundColor:[UIColor blueColor]];
    [btnAllDelete setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnAllDelete.titleLabel.font=[UIFont systemFontOfSize:14];
    btnAllDelete.autoresizingMask=UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
    [btnAllDelete addTarget:self action:@selector(deleteAllDownloadTask:) forControlEvents:UIControlEventTouchUpInside];
    [self.vwHeader addSubview:btnAllDelete];
    self.btnAllDelete = btnAllDelete;
    
    CKLastTouchButton * btnAllDownload=[[CKLastTouchButton alloc] init];
    btnAllDownload.frame=CGRectMake(self.vwHeader.frame.size.width-90,45, 80, 30);
    [btnAllDownload setTitle:@"全部开始" forState:UIControlStateNormal];
    [btnAllDownload setBackgroundColor:[UIColor blueColor]];
    [btnAllDownload setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnAllDownload.titleLabel.font=[UIFont systemFontOfSize:14];
    btnAllDownload.autoresizingMask=UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
    [self.vwHeader addSubview:btnAllDownload];
    self.btnAllDownload = btnAllDownload;
    
    
    //every time touch change the word of button, but not work any function ,when the last touch, the button function.
    __weak typeof(self)weakSelf = self;
    [self.btnAllDownload setTouchUpInsideEveryTimeActionBlock:^(UIButton *sender) {
        
    } finalAcitonBlock:^(UIButton *sender) {
        if(weakSelf.tapState)
        {
            [[CKDownloadManager sharedInstance] pauseAll];
        }
        else
        {
            [[CKDownloadManager sharedInstance] startAllWithCancelBlock:^{
                
            }];
        }
        
    }];
    
    [self configDownloadAllButton];
    
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

    self.tapState= [CKDownloadManager sharedInstance].isHasDownloading;
}

-(void) downloadChanged:(id<CKDownloadModelProtocol>) model  isFilter:(BOOL) isFiltered {
    [self configDownloadAllButton];
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

-(void) installUrl:(NSURL*) url  remoteAddress:(NSString *) address
{
    NSString * name =[url lastPathComponent];
    NSString * pureName=[name stringByDeletingPathExtension];
    NSString * urlStr=[NSString stringWithFormat:@"itms-services://?action=download-manifest&url=%@%@.plist",address,pureName];
    NSURL *plistUrl = [NSURL URLWithString:urlStr];
    [[UIApplication sharedApplication] openURL:plistUrl];
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

-(void) configEditModeWithCell:(UITableViewCell<CKDownloadTableViewCellProtocol> *) cell
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


#pragma mark - override cell
-(void) clickCompleteButton:(id<CKDownloadModelProtocol>) model {
    CKDownloadFileModel * fModel = (CKDownloadFileModel *)model;
    [self installUrl:URL(fModel.plistURL) remoteAddress:fModel.address];
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView ==self.tbDownloading)
    {
        return  [CKInternalAppInstallDownloadingTableViewCell getHeight];
    }
    else
    {
        return  [CKInternalAppInstallDownloadCompleteTableViewCell getHeight];
    }
}


- (Class) downloadingCellClass
{
    return [CKInternalAppInstallDownloadingTableViewCell class];
}

- (Class) downloadCompleteCellClass
{
    return [CKInternalAppInstallDownloadCompleteTableViewCell class];
}

- (void) customConfigDownloadingCell:(CKBaseDownloadingTableViewCell *) downloadingCell model:(id<CKDownloadModelProtocol>) model
{
    
    [self configEditModeWithCell:downloadingCell];
}

- (void) customConfigDownloadCompleteCell:(CKBaseDownloadCompleteTableViewCell *)downloadCompleteCell model:(id<CKDownloadModelProtocol>) model
{
    CKInternalAppInstallDownloadCompleteTableViewCell * internalInstallCell = (CKInternalAppInstallDownloadCompleteTableViewCell*) downloadCompleteCell;
    CKDownloadFileModel * fileModel = (CKDownloadFileModel *) model;
    
    internalInstallCell.lblDownloadVersion.text=[NSString stringWithFormat:@"版本:%@",fileModel.fileVersion];
    internalInstallCell.lblDownloadInfomation.text=[NSString stringWithFormat:@"简介:%.1fM|%@",B_TO_M(fileModel.totalCotentSize) ,fileModel.downloadDate];
    
    [self configEditModeWithCell:downloadCompleteCell];
}

@end
