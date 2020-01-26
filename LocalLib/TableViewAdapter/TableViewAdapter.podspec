Pod::Spec.new do |s|
  s.name         = "TableViewAdapter"
  s.version      = "0.0.1"
  s.summary      = "A lightweight tableview adapter."
  s.description  = "TableViewAdapter is a lightweight tableview adapter framework."

  s.homepage     = "https://www.qyizhong.cn"
  s.license      = "MIT"
  s.author             = { "Q YiZhong" => "178159283@qq.com" }
  s.source       = { :git => "", :tag => "#{s.version}" }
  s.source_files  = "Classes", "Classes/**/*.swift"
  s.exclude_files = "Classes/Exclude"

end
