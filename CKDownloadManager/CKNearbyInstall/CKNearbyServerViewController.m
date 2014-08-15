//
//  CKNearbyServerViewController.m
//  aisiweb
//
//  Created by Mac on 14-6-23.
//  Copyright (c) 2014年 weiaipu. All rights reserved.
//

#import "CKNearbyServerViewController.h"
#import "BonjourBrowser.h"
#import "CKNearbyService.h"
#import "CKNearbyServerDownloadedAppViewController.h"
#import "CKSingletonHTTPServer.h"
#import "DTAlertView.h"
#import "CKNearbyMacro.h"

@interface CKNearbyServerViewController ()<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,strong) UITableView *tbServer;
@property(nonatomic,strong) NSMutableArray * serversAry;


@property(nonatomic,strong) BonjourBrowser * browser;
@end

@implementation CKNearbyServerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.serversAry=[NSMutableArray array];
    }
    return self;
}

-(void) loadView
{
    [super loadView];
    
    self.tbServer=[[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    self.tbServer.delegate=self;
    self.tbServer.dataSource=self;
    self.tbServer.autoresizingMask=UIViewAutoresizingFlexibleHeight;
    self.tbServer.allowsSelection=YES;
    [self.view addSubview:self.tbServer];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self browserBonjour];
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
    return self.serversAry.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *  CellIdentifier=@"com.CKNearbyServerViewController.UITableViewCell";
    UITableViewCell * cell=[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(!cell)
    {
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    
    CKNearbyService * server=[self.serversAry objectAtIndex:indexPath.row];
    cell.textLabel.text=server.name;
    cell.textLabel.font=[UIFont systemFontOfSize:15];
    
//    switch (server.connectionState) {
//        case kCSDisconnected:
//        {
//            cell.detailTextLabel.text=@"断开";
//        }
//            break;
//        case kCSConnected:
//        {
//            cell.detailTextLabel.text=@"已连接";
//        }
//            break;
//            
//        default:
//            break;
//    }
    
    
    return cell;
}



#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    CKNearbyService * server=[self.serversAry objectAtIndex:indexPath.row];
    
    NSString * msg=[NSString stringWithFormat:@"是否连接:%@",server.name];
    CXAlertView * alert=[[CXAlertView alloc] initWithTitle:@"提示" message:msg cancelButtonTitle:@"取消"];
    [alert addButtonWithTitle:@"确定" type:CXAlertViewButtonTypeDefault handler:^(CXAlertView *alertView, CXAlertButtonItem *button) {
        
        CKNearbyServerDownloadedAppViewController *  appVC=[[CKNearbyServerDownloadedAppViewController alloc] init];
        appVC.service=server;
        appVC.title=server.name;
        UINavigationController * navVC=[[UINavigationController alloc] initWithRootViewController:appVC];
        [self presentViewController:navVC animated:YES completion:nil];
        [alertView dismiss];
    }];
    
    [alert show];
}



#pragma mark - browser bonjour
-(void) browserBonjour
{
    self.browser=[[BonjourBrowser alloc] init];
    [self.browser browserDomain:@"local." type:@"_http._tcp."];
    
    NSString * serviceName=[CKSingletonHTTPServer sharedInstance].serviceNameIdentifier;
    
    __weak typeof(self)weakSelf = self;
    self.browser.browseNewServiceBlock=^(NSNetService * service, NSString * addressString){
        NSDictionary * txtDictionary=[NSNetService dictionaryFromTXTRecordData:service.TXTRecordData];
        NSString * textContent=[[NSString alloc ] initWithData:[txtDictionary objectForKey:APP_KEY] encoding:NSUTF8StringEncoding];
        
        if([textContent isEqualToString:serviceName])
        {
            [[NSUserDefaults standardUserDefaults] setObject:service.name forKey:SELF_DEVICE_NAME_KEY];
        }
        
        if(textContent.length>0  && ![textContent isEqualToString:serviceName] && ![addressString isEqualToString:@"0.0.0.0"])
        {
            CKNearbyService * server=[[CKNearbyService alloc] init];
            server.name=service.name;
            server.address=addressString;
            server.serviceIdentifier=serviceName;
            [weakSelf.serversAry addObject:server];
            
            [weakSelf.tbServer reloadData];
        }
    };
    
    self.browser.browseRemoveServiceBlock=^(NSNetService * service){
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^(void) {
            NSArray * serviceArray=[weakSelf.serversAry copy];
            for (CKNearbyService * emService in serviceArray) {
                if([emService.name isEqualToString:service.name])
                {
                    dispatch_async(dispatch_get_main_queue(), ^(void) {
                        emService.connectionState=kCSDisconnected;
                        [weakSelf.serversAry removeObject:emService];
                        [weakSelf.tbServer reloadData];
                        
                        NSString * msg=[NSString stringWithFormat:@"%@已经与您断开",service.name];
                        DTAlertView * alertview=[DTAlertView alertViewUseBlock:^(DTAlertView *alertView, NSUInteger buttonIndex, NSUInteger cancelButtonIndex) {
                         
                            [weakSelf dismissViewControllerAnimated:YES completion:nil];
                    
                        } title:@"温馨提示" message:msg cancelButtonTitle:@"确定" positiveButtonTitle:nil];
                        
                        [alertview show];
                    });
                    
                    break ;
                }
            }
            
        });

    };
}




@end
