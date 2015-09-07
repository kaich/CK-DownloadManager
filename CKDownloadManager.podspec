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
CKDownloadManager is a download framework.There are more features compare other download Framekwork.The features as below:

Download base function
Download multi task
Download task filter(eg: You download pdf that contain a cover image,but you only show pdf download progress.so you can use filter to show pdf progress only);
Download task dependency(eg: whenever cover download completely before pdf download starts)
Download multi validate
Download timeout retry
Download with multi newwork library
Singleton or Multi download manager
Download extension function
Custom your own task info
The outstanding performance
                       DESC

  s.homepage         = "https://github.com/kaich/CKDownloadManager"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "kaich" => "chengkai1853@163.com" }
  s.source           = { :git => "https://github.com/kaich/CKDownloadManager.git", :tag => "1.0.0" }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/*/*'
  s.resource_bundles = {
    'CKDownloadManager' => ['Pod/Assets/*.png']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'

  s.library   = "sqlite3.0"
  s.dependency "LKDBHelper" 
  s.dependency "CocoaHTTPServer"
  s.dependency "DTAlertView"
  s.dependency "ASIHTTPRequest"
  s.dependency "SDWebImage"
  s.dependency "Reachability"

  
  #s.subspec 'Core' do |ss|
		 #ss.source_files = 'Pod/Classes/Core/*.{h,m}'
  #end

  #s.subspec 'DownloadViewController' do |ss|
		 #ss.source_files = 'Pod/Classes/DownloadViewController/*.{h,m}'
     #ss.dependency "SDWebImage"
  #end

  #s.subspec 'Extension' do |ss|
		 #ss.source_files = 'Pod/Classes/Extension/*.{h,m}'
  #end

  #s.subspec 'Util' do |ss|
		 #ss.source_files = 'Pod/Classes/Util/*.{h,m}'
  #end
end
