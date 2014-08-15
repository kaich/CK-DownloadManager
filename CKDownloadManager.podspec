Pod::Spec.new do |s|

  s.name         = "CKDownloadManager"
  s.version      = "1.0.0"
  s.summary      = "A  CKDownloadManager"
  s.description  = <<-DESC
                   A longer description of CKDownloadManager in Markdown format.

                   * Think: Why did you write this? What is the focus? What does it do?
                   * CocoaPods will be using this to generate tags, and improve search results.
                   * Try to keep it short, snappy and to the point.
                   * Finally, don't worry about the indent, CocoaPods strips it!
                   DESC

  s.homepage     = "https://github.com/kaich/CKDownloadManager"




  s.license      = "MIT (example)"



  s.author             = { "kai cheng " => "chengkai1853@163.com" }


  s.platform     = :ios, "5.0"


  s.source       = { :git => "https://github.com/kaich/CKDownloadManager.git", :tag => "1.0.0" }


  s.source_files  = "Classes", "Classes/**/*.{h,m}"
  s.exclude_files = "Classes/Exclude"
  s.library   = "sqlite3.0"
  s.requires_arc = true


  s.dependency "LKDBHelper" "HTTPServer"  "DTAlertView"

end
