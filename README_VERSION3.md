CKDownloadManager
=================


[![CI Status](http://img.shields.io/travis/kaich/CKDownloadManager.svg?style=flat)](https://travis-ci.org/kaich/CKDownloadManager)
[![Version](https://img.shields.io/cocoapods/v/CKDownloadManager.svg?style=flat)](http://cocoapods.org/pods/CKDownloadManager)
[![License](https://img.shields.io/cocoapods/l/CKDownloadManager.svg?style=flat)](http://cocoapods.org/pods/CKDownloadManager)
[![Platform](https://img.shields.io/cocoapods/p/CKDownloadManager.svg?style=flat)](http://cocoapods.org/pods/CKDownloadManager)


#### `CKDownloadManager`

一个支持断点续传下载的管理器，只需要实现它的代理，就可以很方便的使用它。

#####安装
你可以通过Pod来安装它：
	
	pod 'CKDownloadManager',:git=>"https://github.com/kaich/CKDownloadManager.git"

这个工程适配了`AFNetworking`和`ASIHTTPRequest`以及`NSURLSessionTask`这三种库。你可以任选一种，当然你也可以实现`CKURLDownloadTaskProtocol`代理来适配你自己的网络库。下面是`AFNetworking`的使用方式：

	pod "CKDownloadManager",:subspecs => ['Core','UI/InternalAppInstallUI','Extension/AFNetworkingAdaptor'], :git=>"https://github.com/kaich/CKDownloadManager.git"
	
####特点
CKDownloadManager是一个对下载的封装库。它和其他封装库相比有着更多的特性，具体如下：

* 基本下载功能
* 多种不同类型下载任务（图片，音频，视频 都可以下载，直接在model中标记区分即可）
* 任务过滤器（比如你下载一个PDF文件，它包含另外一个图片文件，但是你只想现在PDF文件的下载进度，那么利用过滤器可以很方便的实现这种功能）
* 下载任务依赖（还是PDF和图片的例子，如果你要保证图片下载完成之后再下载PDF，那么可以利用该依赖功能）
* 下载校验（长度校验，伪MD5校验）
* 兼容多种网络库（例如之前提及的：`AFNetworking` `ASIHTTPRequest`和`NSURLSessionTask`）
* 自定义任务信息（继承CKDownloadBaseModel模型类或者实现CKDownloadModelProtocol协议）
* 优秀的性能


####下载基础功能
下载必须包含的基本功能：开始 暂停 继续下载 删除任务

* 开始下载
	
		NSString * downloadUrl =@"http://7xl9a5.com2.z0.glb.qiniucdn.com/%E4%B8%AD%E7%8F%AD.mp4?attname=";
    	CKDownloadBaseModel * model = [[CKDownloadBaseModel alloc] init];
   		model.URLString = downloadUrl;
    	[[CKDownloadManager sharedInstance] startDownloadWithURL:URL(downloadUrl) entity: model];
    
* 暂停

		[[CKDownloadManager sharedInstance] pauseWithURL:URL(downloadUrl)];
	
* 继续下载

		[[CKDownloadManager sharedInstance] resumWithURL:URL(downloadUrl)];  
		
* 删除
	* 删除单个
	
			[[CKDownloadManager sharedInstance] deleteWithURL:URL(downloadUrl)];  
	
	* 删除所有下载列表
		
			[[CKDownloadManager sharedInstance] deleteAllWithState:YES];
		
	* 删除所有已下载
		
			[[CKDownloadManager sharedInstance] deleteAllWithState:NO];	
	
#####过滤器
你可以下载各种不同类型的任务，因此一定程度上你需要区分它和进行过滤。例如你下载一个ipa的包，它可能包含其他附件plist,图片等等。你不想显示图片和plist的下载任务。那么可以这么做：

	filter.filterParams=@"NOT(URLString  CONTAINS[cd] 'plist' OR URLString  CONTAINS[cd] 'jpg' OR URLString  CONTAINS[cd] 'png' OR URLString  CONTAINS[cd] 'jpeg')";

你也可以用`filterConditionBlock`来实现过滤
	

#####依赖
如果一个任务依赖另外一个任务的完成。可以如下方法

	-(void) startDownloadWithURL:(NSURL *)URL entity:(id<CKDownloadModelProtocal>)entity dependencies:(NSDictionary *) dependencyDictionary;
	
#####下载校验
`CKDownloadFileValidator`是一个校验器。它包含了文件大小校验，文件类容校验和剩余空间校验。如果你设置了校验器，那么只需要设置如下开关即可，他们默认是全部YES

* isValidateFileSize
* isValidateFileContent
* isValidateFreeSpace

当你要进行内容校验的时候，请在你的服务器端同样实现`generateValidateCodeWithURL`里面生成校验码的算法。

#####下载重试
如果你设置`CKDownloadRetryController`，那么它下载之前会进行头文件比对，如果成功继续下载，如果失败会进行重试。

	CKDownloadRetryController * retryController = [[CKDownloadRetryController alloc] init];
    retryController.retryMaxCount=20;
    [[CKDownloadManager sharedInstance].retryController = retryController;
   
如果他重试超过了retryMaxCount，那么该任务会移动到任务列表最下端，让其他任务优先下载，等待重新尝试下载

#####多网络库
[ASIHttpRequest]: (https://github.com/pokeb/asi-http-request)
[AFNetworking]: (https://github.com/AFNetworking/AFNetworking)
[NSURLSession]: (https://developer.apple.com/library/ios/documentation/Foundation/Reference/NSURLSession_class/)

* [ASIHttpRequest]
* [AFNetworking]
* [NSURLSession]

你再你的工程里面使用了哪一个网络库？ [ASIHttpRequest]、[AFNetworking]、[NSURLSession]还是其他？CKDownloadManager 已经提供给你了这三种网络库的适配。如果你想利用其他网络库，你可以实现`CKURLDownloadTaskProtocol`来进行适配。例如使用[AFNetworking]

	[[CKDownloadManager sharedInstance] setDownloadTaskClass:[AFNetWorkingAdaptor class]];


#####优秀的性能
性能对于下载而言是尤为重要的。CKDownloadManager有着不错的性能。里面进行了许多多线程之间的同步和异步操作。

##### Author

kaich, chengkai1853@163.com

##### License

CKDownloadManager is available under the MIT license. See the LICENSE file for more info.