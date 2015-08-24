CKDownloadManager
=================

A  CKDownloadManager

A Download manager surport resum download. You only implement the delegate.It is simple to use.
######Install 
You Use it in your project with [CocoaPods](https://github.com/CocoaPods/CocoaPods)

	pod 'CKDownloadManager',:git=>"https://github.com/kaich/CKDownloadManager.git"

#####Feature
CKDownloadManager is a download framework.There are more features compare other download Framekwork.The features as below:

* Download base function
* Download multi task 
* Download task filter(eg: You download pdf that contain a cover image,but you only show pdf download progress.so you can use filter to show pdf progress only);
* Download task dependency(eg: whenever cover download completely before pdf download starts) 
* Download multi validate
* Download timeout retry 
* Download with multi newwork library  
* Singleton or Multi download manager
* Download extension function
* Custom your own task info
* The outstanding performance

#####Download base function
Download manager must contain base function as such as start ,pause, resum and delete. CKDownloadManager also contains those. eg:
You can start a simple download task as below:


    NSString * downloadUrl =@"http://7xl9a5.com2.z0.glb.qiniucdn.com/%E4%B8%AD%E7%8F%AD.mp4?attname=";
    CKDownloadBaseModel * model = [[CKDownloadBaseModel alloc] init];
    model.URLString = downloadUrl;
    [[CKDownloadManager sharedInstance] startDownloadWithURL:URL(downloadUrl) entity: model];


If you want pause it, you can invoke `pauseWithURL` as below:
    
    [[CKDownloadManager sharedInstance] pauseWithURL:URL(downloadUrl)];

Of course you can resum as below:

    [[CKDownloadManager sharedInstance] resumWithURL:URL(downloadUrl)];  

Delete a task as below:

    [[CKDownloadManager sharedInstance] deleteWithURL:URL(downloadUrl)];  

Delete all downloading task as below:

    [[CKDownloadManager sharedInstance] deleteAllWithState:YES];

If you want delete all download completely task, you only change param to NO. Delete All task, you can do it like this.

    [[CKDownloadManager sharedInstance] deleteAllWithState:YES];
    [[CKDownloadManager sharedInstance] deleteAllWithState:NO];
    

#####Download multi task 
You can download your many kind of task with CKDownloadManager.You have books and videos.If you want to download those two, you can simple to do this.You only distinguish between them by model.

#####Download task filter
You have books and videos.You only want to show videos in you tableview.You can use `CKDownloadFilter`.Use `filterParams` or `filterConditionBlock` to set filter condition.For example, you don't want to show png and jpg ,plist, jpeg task. 

    filter.filterParams=@"NOT(URLString  CONTAINS[cd] 'plist' OR URLString  CONTAINS[cd] 'jpg' OR URLString  CONTAINS[cd] 'png' OR URLString  CONTAINS[cd] 'jpeg')";

Of course you also can use `filterConditionBlock` to do it.

#####Download task dependency
If you one task depends on another task completely.My download manager also can fit you. 

    -(void) startDownloadWithURL:(NSURL *)URL entity:(id<CKDownloadModelProtocal>)entity dependencies:(NSDictionary *) dependencyDictionary;

#####Download multi validate
`CKDownloadFileValidator` is a validator contains file size , file content and free space validation.If you want wihch validation, you only set the relevant property to yes. 

* isValidateFileSize
* isValidateFileContent
* isValidateFreeSpace

when you want to realize file content validation, you must realize `generateValidateCodeWithURL` method in your server.
