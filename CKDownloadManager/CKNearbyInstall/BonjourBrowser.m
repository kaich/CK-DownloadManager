//
//  BonjourBrowser.m
//  aisiweb
//
//  Created by Mac on 14-6-19.
//  Copyright (c) 2014年 weiaipu. All rights reserved.
//

#import "BonjourBrowser.h"
#import "CKNearbyService.h"

@interface BonjourBrowser ()<NSNetServiceBrowserDelegate,NSNetServiceDelegate>
@property(nonatomic,strong) NSNetServiceBrowser * serviceBrowser;


@property(nonatomic,strong) NSString * domian;
@property(nonatomic,strong) NSString * type;

@end

@implementation BonjourBrowser

-(void) browserDomain:(NSString*) domain  type:(NSString*) type
{
    self.domian=domain;
    self.type=type;
    self.servicesAry=[NSMutableArray array];
    
    
    self.serviceBrowser=[[NSNetServiceBrowser alloc] init];
    if(!self.serviceBrowser) {
        NSAssert(self.serviceBrowser, @"The NSNetServiceBrowser couldn't be allocated and initialized.");
		return ;
	}
    self.serviceBrowser.delegate=self;
    [self.serviceBrowser searchForServicesOfType:type inDomain:domain];
}


#pragma mark - NSNetServiceBrowserDelegate
-(void) netServiceBrowserWillSearch:(NSNetServiceBrowser *)aNetServiceBrowser
{
    NSLog(@"wil start browser");
}

-(void) netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didNotSearch:(NSDictionary *)errorDict
{
    CFShow((__bridge CFTypeRef)(errorDict));
}


- (void)netServiceBrowser:(NSNetServiceBrowser*)netServiceBrowser didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing
{
    
    if(![self.servicesAry containsObject:aNetService])
    {
        [self.servicesAry addObject:aNetService];
        
        aNetService.delegate=self;
        [aNetService resolveWithTimeout:2.0];
        
        NSLog(@"start bonjour resolve");
    }
    

}


-(void) netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didRemoveService:(NSNetService *)aNetService moreComing:(BOOL)moreComing
{
    if([self.servicesAry containsObject:aNetService])
    {
        [self.servicesAry removeObject:aNetService];
        
        if(self.browseRemoveServiceBlock)
            self.browseRemoveServiceBlock(aNetService);
    }
}




#pragma mark -  NSNetService delegate

-(void) netServiceDidResolveAddress:(NSNetService *)sender
{


    for (NSData *dataIn in sender.addresses) {
        struct sockaddr_in  *socketAddress = nil;
        NSString  *socketString = nil;
        socketAddress = (struct sockaddr_in *)[dataIn bytes];
        NSString * addressString=[NSString stringWithCString:inet_ntoa(socketAddress->sin_addr) encoding:NSUTF8StringEncoding];
       
        
        socketString = [NSString stringWithFormat: @"解析结果:%@   %s:%d", sender.name, inet_ntoa(socketAddress->sin_addr), sender.port];
        
        if(self.browseNewServiceBlock)
            self.browseNewServiceBlock(sender,addressString);
    }
}


@end
