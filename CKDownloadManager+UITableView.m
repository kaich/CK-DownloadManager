//
//  CKDownloadManager+UITableView.m
//  aisiweb
//
//  Created by Mac on 14-6-11.
//  Copyright (c) 2014年 weiaipu. All rights reserved.
//

#import "CKDownloadManager+UITableView.h"
#import <objc/runtime.h>

static NSString * CompleteExtralBlock=nil;

@implementation CKDownloadManager (UITableView)
@dynamic downloadCompleteExtralBlock;

-(void) setDownloadingTable:(UITableView *)downloadingTableView completeTable:(UITableView *)completeTableView
{
    
    
    __weak typeof(self)weakSelf = self;
    
    self.downloadCompleteBlock=^(CKDownloadBaseModel * model , NSInteger exutingIndex,NSInteger completeIndex ,BOOL isFiltered){
        
        if(isFiltered)
        {
            NSIndexPath * indexPath=[NSIndexPath indexPathForRow:exutingIndex inSection:0];
            [downloadingTableView beginUpdates];
            [downloadingTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [downloadingTableView endUpdates];
            
            NSIndexPath * indexPathComplete=[NSIndexPath indexPathForRow:completeIndex inSection:0];
            [completeTableView beginUpdates];
            [completeTableView insertRowsAtIndexPaths:@[indexPathComplete] withRowAnimation:UITableViewRowAnimationAutomatic];
            [completeTableView endUpdates];
        }
        
        if(!isFiltered)
        {
            if(weakSelf.downloadCompleteExtralBlock)
                weakSelf.downloadCompleteExtralBlock(model,exutingIndex,completeIndex,isFiltered);
        }
    };
    
    
    self.downloadDeletedBlock=^(id<CKDownloadModelProtocal> model ,NSInteger index ,BOOL isComplete){
        
        NSIndexPath * indexPath=[NSIndexPath indexPathForRow:index inSection:0];
        
        if(isComplete)
        {
            [completeTableView beginUpdates];
            [completeTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [completeTableView endUpdates];
        }
        else
        {
            [downloadingTableView beginUpdates];
            [downloadingTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [downloadingTableView endUpdates];
        }
    };
    
    self.downloadStartBlock=^(id<CKDownloadModelProtocal> downloadTask, NSInteger index){
        NSIndexPath * indexPath=[NSIndexPath indexPathForRow:index inSection:0];
        
        [downloadingTableView beginUpdates];
        [downloadingTableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [downloadingTableView endUpdates];
    };

}


-(void) setDownloadCompleteExtralBlock:(DownloadFinishedBlock)downloadCompleteExtralBlock
{
    objc_setAssociatedObject(self, &CompleteExtralBlock, downloadCompleteExtralBlock, OBJC_ASSOCIATION_COPY);
}

-(DownloadFinishedBlock) downloadCompleteExtralBlock
{
  return   objc_getAssociatedObject(self, &CompleteExtralBlock);
}

@end
