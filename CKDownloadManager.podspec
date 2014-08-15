Pod::Spec.new do |s|
  s.name         = "CKDownloadManager"
  s.version      = "1.0.0"
  s.summary      = "A  CKDownloadManager"
  s.homepage     = "https://github.com/kaich/CKDownloadManager"
  s.license      = "MIT"
  s.author       = { "kai cheng " => "chengkai1853@163.com" }
  s.platform     = :ios, "5.0"
  s.ios.deployment_target = "5.0"
  s.source       = { :git => "https://github.com/kaich/CKDownloadManager.git", :tag => "1.0.0" }
  s.source_files  = "CKDownloadManager/*.{h,m}"
  s.library   = "sqlite3.0"
  s.dependency "LKDBHelper" 
  s.dependency  "CocoaHTTPServer"
  s.dependency "DTAlertView"

  s.subspec 'Core' do |ss|
	   ss.source_files = 'CKDownloadManager/Core/*.{h,m}'
   end

  s.subspec 'DownloadViewController' do |ss|
	   ss.source_files = 'CKDownloadManager/DownloadViewController/*.{h,m}'
   end

  s.subspec 'Extension' do |ss|
	   ss.source_files = 'CKDownloadManager/Extension/*.{h,m}'
   end

  s.subspec 'Util' do |ss|
	   ss.source_files = 'CKDownloadManager/Util/*.{h,m}'
   end
end
