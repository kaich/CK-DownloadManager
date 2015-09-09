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

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  #s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'CKDownloadManager' => ['Pod/Assets/*.png']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'

  s.default_subspecs = 'Core' , 'DownloadViewController' , 'Extension/ASIHTTPRequestAdaptor'
  
  s.subspec 'Core' do |ss|
     ss.source_files = 'Pod/Classes/Core/*.{h,m}' , 'Pod/Classes/Component/*.{h,m}'
     ss.library   = "sqlite3.0"
     ss.dependency "LKDBHelper" 
     ss.dependency "Reachability"
     ss.dependency "DTAlertView"
  end

  s.subspec 'DownloadViewController' do |ss|
     ss.source_files = 'Pod/Classes/DownloadViewController/*.{h,m}' , 'Pod/Classes/Util/*.{h,m}'
     ss.dependency 'CKDownloadManager/Core'
     ss.dependency 'CKDownloadManager/Extension/FileModel'
     ss.dependency "SDWebImage"
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
