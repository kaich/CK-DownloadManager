//
//  CKViewController.m
//  CKDownloadManager
//
//  Created by kaich on 09/07/2015.
//  Copyright (c) 2015 kaich. All rights reserved.
//

#import "CKViewController.h"
#import "CKDownloadManagerViewController.h"
#import "CKDownloadFileModel.h"
#import "CKDownloadManager.h"
#import "ShareXmlParser.h"
#import "AppListRecord.h"


@interface CKViewController ()
{
    ShareXmlParser * _shareXml;
}
@end

@implementation CKViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)getMoreApp{
    
        NSString *urlStr = @"http://ios3.app.i4.cn/getAppList.xhtml?model=iPhone3,1&isAuth=1&type=0&remd=1&specialid=0&pageno=1&isjail=0&toolversion=1";
        
        _shareXml = [[ShareXmlParser alloc] init];
        [_shareXml startRequestWithUrl:urlStr];
    
        _shareXml.failHandler=^(NSError *error){
        };
        
        _shareXml.SuccessHandler = ^(NSArray *ary1, NSArray *ary2){
            for (AppListRecord * appRecord in ary2) {
                
                CKDownloadFileModel * model=[[CKDownloadFileModel alloc] init];
                model.title=appRecord.appName;
                model.plistURL=appRecord.plist;
                model.plistURL=appRecord.icon;
                model.fileVersion=appRecord.version;
                model.standardFileSize = appRecord.sizebyte;
                
                
                CKDownloadFileModel * model2=[[CKDownloadFileModel alloc] init];
                model2.title=appRecord.appName;
                model2.plistURL=appRecord.plist;
                model2.imgURLString=appRecord.icon;
                model2.fileVersion=appRecord.version;
                
                [[CKDownloadManager sharedInstance] startDownloadWithURL:URL(appRecord.path) entity:model];
                [[CKDownloadManager sharedInstance] startDownloadWithURL:URL(appRecord.plist) entity:model2];
            }
        };
}

-(void) showDownload
{
    CKDownloadManagerViewController * downloadVC = [[CKDownloadManagerViewController alloc] init];
    [self presentViewController:downloadVC animated:YES completion:nil];
}

- (IBAction)EnterDownloadPage:(id)sender {
    [self getMoreApp];
    [self showDownload];
}
@end
