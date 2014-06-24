//
//  CKNearbyServerDownloadedAppViewController.m
//  aisiweb
//
//  Created by Mac on 14-6-23.
//  Copyright (c) 2014年 weiaipu. All rights reserved.
//

#import "CKNearbyServerDownloadedAppViewController.h"
#import "CKRefrenceRequestManager.h"
#import "CKDownloadManager.h"
#import "CKDownloadPlistFactory.h"
#import "CKDownloadFinishedTableViewCell.h"
#import "MBFlatAlertView.h"
#import "CKNearbyMacro.h"

@interface CKNearbyServerDownloadedAppViewController ()<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,strong) UITableView * tbNearbyApp;

@property(nonatomic,strong) NSArray * nearbyApps;
@end

@implementation CKNearbyServerDownloadedAppViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void) loadView
{
    [super loadView];
    
    
    self.tbNearbyApp=[[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    self.tbNearbyApp.delegate=self;
    self.tbNearbyApp.dataSource=self;
    self.tbNearbyApp.autoresizingMask=UIViewAutoresizingFlexibleHeight;
    self.tbNearbyApp.separatorStyle=UITableViewCellSeparatorStyleNone;
    self.tbNearbyApp.allowsSelection=NO;
    [self.view addSubview:self.tbNearbyApp];
    
    
    UIBarButtonItem * bbiCancel=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissViewController)];
    self.navigationItem.leftBarButtonItem=bbiCancel;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    CKRefrenceRequestManager * mgr=[[CKRefrenceRequestManager alloc] init];
    mgr.completeBlock=^(id result){

        for (CKDownloadFileModel* emModel in result) {
            emModel.address=[NSString stringWithFormat:@"http://%@:12345/",self.service.address];
            [[CKDownloadManager sharedInstance] startDownloadWithURL:URL(emModel.plistURL) entity:nil];
            [CKDownloadPlistFactory createPlistWithURL:URL(emModel.plistURL) iconImageURL:URL(emModel.imgURLString) appURL:URL(emModel.appURL) baseURL:BaseInstallURL];
            
        }
        
        self.nearbyApps=result;
        [self.tbNearbyApp reloadData];
    };
    
    
    mgr.failedBlock=^(id result){
        NSString * msg=nil;
        if([result isKindOfClass:[NSError class]])
        {
            msg=@"连接出错";
        }
        else
        {
            msg=result;
        }
         MBFlatAlertView * alertView=[MBFlatAlertView alertWithTitle:@"温馨提示" detailText:msg cancelTitle:@"确定" cancelBlock:^{
             
         }];
        [alertView addToDisplayQueue];
    };
    
    
    [mgr getRefrenceDownloadByAddress:self.service.address deviceNameIdentifier:SELF_DEVICE_NAME_VALUE];
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
    return self.nearbyApps.count;
}

-(float) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [CKDownloadFinishedTableViewCell getHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * CellIdentifier=@"CKDownloadFinishTableViewCell";
    CKDownloadFinishedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(!cell)
    {
        cell=[[CKDownloadFinishedTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    CKDownloadFileModel* model=[self.nearbyApps objectAtIndex:indexPath.row];
    
    cell.clickBlock=^(){
        [self installUrl:URL(model.plistURL) remoteAddress:model.address];
    };
    
    
    cell.deleteBlock=^(CKBaseTableViewCell * theCell){
        NSInteger index=[tableView indexPathForCell:theCell].row;
        CKDownloadBaseModel * model=[[CKDownloadManager sharedInstance].downloadCompleteEntities objectAtIndex:index];
        [[CKDownloadManager sharedInstance] deleteWithURL:URL(model.URLString)];
    };
    
    
    
    cell.lblTitle.text=model.title;
    cell.lblDownloadInfo.text=[NSString stringWithFormat:@"版本%@|%.1fM|%@",model.fileVersion,[model.totalCotentSize floatValue],model.downloadDate];
    [cell.ivImage setImageWithURL:URL(model.imgURLString) placeholderImage:[UIImage imageNamed:@"Placeholder_iPhone"]];
    
    return  cell;
}



#pragma mark - private method
-(void) installUrl:(NSURL*) url  remoteAddress:(NSString *) address
{
    NSString * name =[url lastPathComponent];
    NSString * pureName=[name stringByDeletingPathExtension];
    NSString * urlStr=[NSString stringWithFormat:@"itms-services://?action=download-manifest&url=%@%@.plist",address,pureName];
    NSURL *plistUrl = [NSURL URLWithString:urlStr];
    [[UIApplication sharedApplication] openURL:plistUrl];
}


-(void) dismissViewController
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
