//
//  ViewController.m
//  NSURLSessionDownloadManager
//
//  Created by mac on 16/2/16.
//  Copyright © 2016年 kaicheng. All rights reserved.
//

#import "ViewController.h"
#import "ShareXmlParser.h"
#import "AppListRecord.h"
#import "CKDownloadManager.h"
#import "CKDownloadFileModel.h"
#import "CKInternalAppInstallDownloadManagerViewController.h"

@interface ViewController ()
{
    ShareXmlParser * _shareXml;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)getMoreApp{
    
    NSString *urlStr = @"http://ios3.app.i4.cn/getAppList.xhtml?idfa=E96ED53F-B955-42D5-9CE1-DE120DF6A8D8&idfv=FF15E480-50A7-4E99-854F-5B3729D751D9&openudid=a5cd7db27cf879bfb6e403841702bc24972ff1c5&osversion=9.2&udid=(null)&macaddress=020000000000&model=iPhone5,1&certificateid=cf02&bundleid=bf02&isAuth=1&isjail=0&authtime=1452072692&serialnumber=C39JT5RKDTTQ&cid=600000&toolversion=712&isAuth=1&sort=2&remd=47&specialid=0&type=&pageno=1&isjail=0&toolversion=712";
    
    _shareXml = [[ShareXmlParser alloc] init];
    [_shareXml startRequestWithUrl:urlStr];
    
    _shareXml.failHandler=^(NSError *error){
    };
    
    _shareXml.SuccessHandler = ^(NSArray *ary1, NSArray *ary2){
        for (AppListRecord * appRecord in ary2) {
            
            CKDownloadFileModel * model=[[CKDownloadFileModel alloc] init];
            model.title=appRecord.appName;
            model.plistURL=appRecord.plist;
            model.imgURLString=appRecord.icon;
            model.fileVersion=appRecord.version;
            model.standardFileSize = appRecord.sizebyte;
            model.dependencies=@[URL(model.imgURLString)];
            
//            //you can set model denpend on model2
//            CKDownloadFileModel * model2=[[CKDownloadFileModel alloc] init];
//            model2.title=appRecord.appName;
//            model2.plistURL=appRecord.plist;
//            model2.imgURLString=appRecord.icon;
//            model2.fileVersion=appRecord.version;
            
            [[CKDownloadManager sharedInstance] startDownloadWithURL:URL(appRecord.path) entity:model dependencies:nil];
//            [[CKDownloadManager sharedInstance] startDownloadWithURL:URL(appRecord.path) entity:model dependencies:@{URL(model.imgURLString) : model2}];
        }
    };
}

-(void) showDownload
{
    CKInternalAppInstallDownloadManagerViewController * downloadVC = [[CKInternalAppInstallDownloadManagerViewController alloc] init];
    [self presentViewController:downloadVC animated:YES completion:nil];
}

- (IBAction)EnterDownloadPage:(id)sender {
    [self getMoreApp];
    [self showDownload];
}

@end
