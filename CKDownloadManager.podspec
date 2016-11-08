#
# Be sure to run `pod lib lint CKDownloadManager.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "CKDownloadManager"
  s.version          = "2.0.0"
  s.summary          = "A Download manager surport resum download. You only implement the delegate.It is simple to use."

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!  
  s.description      = <<-DESC
CKDownloadManager is a download framework.There are more features compare other download Framekwork.
                       DESC

  s.homepage         = "https://github.com/kaich/CKDownloadManager"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "kaich" => "chengkai1853@163.com" }
  s.source           = { :git => "https://github.com/kaich/CKDownloadManager.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  #s.platform     = :ios, '7.0'
  s.ios.deployment_target = '7.0'
  s.osx.deployment_target = '10.9'
  s.requires_arc = true

  #s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'CKDownloadManager' => ['Pod/Assets/*.png']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'

  s.default_subspecs = 'Core' , 'UI' , 'Extension/ASIHTTPRequestAdaptor'
  
  s.subspec 'Core' do |ss|
     ss.source_files = 'Pod/Classes/Core/*.{h,m}' , 'Pod/Classes/Component/*.{h,m}'
     ss.library   = "sqlite3.0"
     ss.dependency "LKDBHelper" 
     ss.dependency "Reachability"
  end

  s.subspec 'UI' do |ss|
     s.ios.deployment_target = '7.0'

     ss.dependency 'CKDownloadManager/Core'

     ss.subspec 'CommonUI' do |sss|
       sss.source_files = 'Pod/Classes/UI/CommonUI/*.{h,m}'
       sss.dependency "DTAlertView"
     end

     ss.subspec 'InternalAppInstallUI' do |sss|
       sss.source_files = 'Pod/Classes/UI/InternalAppInstallUI/*.{h,m}' , 'Pod/Classes/Util/*.{h,m}'
       sss.dependency 'CKDownloadManager/UI/CommonUI'
       sss.dependency 'CKDownloadManager/Extension/FileModel'
       sss.dependency "SDWebImage"
     end
  end


  s.subspec 'Extension' do |ss|
     ss.dependency 'CKDownloadManager/Core'
     

     ss.subspec 'ASIHTTPRequestAdaptor' do |sss|
       sss.source_files = 'Pod/Classes/Extension/ASIHTTPRequestAdaptor/*.{h,m}'
       sss.dependency "ASIHTTPRequest"
     end

     ss.subspec 'AFNetworkingAdaptor' do |sss|
       sss.source_files = 'Pod/Classes/Extension/AFNetworkingAdaptor/*.{h,m}'
       sss.dependency "AFDownloadRequestOperation"
     end

     ss.subspec 'NSURLSessionAdaptor' do |sss|
       sss.source_files = 'Pod/Classes/Extension/NSURLSessionAdaptor/*.{h,m}'
     end

     ss.subspec 'FileModel' do |sss|
       sss.source_files = 'Pod/Classes/Extension/FileModel/*.{h,m}'
     end

     ss.subspec 'HTTPServer' do |sss|
       sss.source_files = 'Pod/Classes/Extension/HTTPServer/*.{h,m}'
       sss.dependency "CocoaHTTPServer"
     end

     ss.subspec 'Nearby' do |sss|
       sss.source_files = 'Pod/Classes/Extension/Nearby/*.{h,m}'
       sss.dependency 'CKDownloadManager/Extension/FileModel'
       sss.dependency "CocoaHTTPServer"
     end

     ss.subspec 'Others' do |sss|
       sss.source_files = 'Pod/Classes/Extension/Others/*.{h,m}'
     end

  end
     
end
