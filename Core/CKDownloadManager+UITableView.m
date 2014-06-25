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
static NSString * DeleteExtralBlock=nil;

@implementation CKDownloadManager (UITableView)
@dynamic downloadCompleteExtralBlock,downloadDeleteExtralBlock;

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
        
        
        if(weakSelf.downloadCompleteExtralBlock)
            weakSelf.downloadCompleteExtralBlock(model,exutingIndex,completeIndex,isFiltered);
        
    };
    
    
    self.downloadDeletedBlock=^(id<CKDownloadModelProtocal> model ,NSInteger index ,BOOL isComplete , BOOL isFiltered){
        
        if(isFiltered)
        {
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
        }
        
        if(weakSelf.downloadDeleteExtralBlock)
        {
            weakSelf.downloadDeleteExtralBlock(model,index,isComplete,isFiltered);
        }
    };
    
    self.downloadStartBlock=^(id<CKDownloadModelProtocal> downloadTask, NSInteger index){
        NSIndexPath * indexPath=[NSIndexPath indexPathForRow:index inSection:0];
        
        [downloadingTableView beginUpdates];
        [downloadingTableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [downloadingTableView endUpdates];
    };
    
    
    self.downloadDeleteAllBlock=^(BOOL isDownloading){
        if(isDownloading)
        {
            CGRect contentRect=CGRectMake(0, 0, downloadingTableView.contentSize.width, downloadingTableView.contentSize.height);
            NSArray * indexPaths=[downloadingTableView indexPathsForRowsInRect:contentRect];
            [downloadingTableView beginUpdates];
            [downloadingTableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
            [downloadingTableView endUpdates];
        }
        else
        {
            CGRect contentRect=CGRectMake(0, 0, completeTableView.contentSize.width, completeTableView.contentSize.height);
            NSArray * indexPaths=[completeTableView indexPathsForRowsInRect:contentRect];
            
            [completeTableView beginUpdates];
            [completeTableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
            [completeTableView endUpdates];
        }
    };
    
    self.downloadDeleteAllExtralBlock=^(id<CKDownloadModelProtocal> model ,NSInteger index ,BOOL isComplete , BOOL isFiltered){
        if(weakSelf.downloadDeleteExtralBlock)
        {
            weakSelf.downloadDeleteExtralBlock(model,index,isComplete,isFiltered);
        }
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


-(void) setDownloadDeleteExtralBlock:(DownloadDeleteBlock)downloadDeleteExtralBlock
{
    objc_setAssociatedObject(self, &DeleteExtralBlock, downloadDeleteExtralBlock, OBJC_ASSOCIATION_COPY);
}

-(DownloadDeleteBlock) downloadDeleteExtralBlock
{
    return  objc_getAssociatedObject(self, &DeleteExtralBlock);
}

@end
