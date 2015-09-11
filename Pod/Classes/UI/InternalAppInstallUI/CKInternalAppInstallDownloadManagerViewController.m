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


@interface CKInternalAppInstallDownloadManagerViewController ()
@property(nonatomic,strong) UIView * vwHeader;
@property(nonatomic,weak) IBOutlet CKLastTouchButton * btnAllDownload;
@property(nonatomic,assign) BOOL tapState;  // YES  all downloading   NO  pause
@end

@implementation CKInternalAppInstallDownloadManagerViewController
@synthesize segmentControl = _segmentControl;
@synthesize btnAllDownload = _btnAllDownload;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
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
    
    self.tapState=[CKDownloadManager sharedInstance].isAllDownloading;
    [self.scrollview addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
    
    
    [[CKDownloadManager sharedInstance] setDownloadingTable:self.tbDownloading completeTable:self.tbDownloadComplete];
    [self configDownloadAllButton];
    
    
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
    
    [self configDownloadAllButton];
    
}

-(void) configDownloadAllButton
{
    [super configDownloadAllButton];
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

#pragma mark - override cell
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

- (void) customConfigDownloadingCell:(CKBaseDownloadingTableViewCell *) downloadingCell model:(id<CKDownloadModelProtocal>) model
{
    
}

- (void) customConfigDownloadCompleteCell:(CKBaseDownloadCompleteTableViewCell *)downloadCompleteCell model:(id<CKDownloadModelProtocal>) model
{
    CKInternalAppInstallDownloadCompleteTableViewCell * internalInstallCell = (CKInternalAppInstallDownloadCompleteTableViewCell*) downloadCompleteCell;
    CKDownloadFileModel * fileModel = (CKDownloadFileModel *) model;
    
    internalInstallCell.lblDownloadVersion.text=[NSString stringWithFormat:@"版本:%@",fileModel.fileVersion];
    internalInstallCell.lblDownloadInfomation.text=[NSString stringWithFormat:@"简介:%.1fM|%@",B_TO_M(fileModel.totalCotentSize) ,fileModel.downloadDate];
}

@end
