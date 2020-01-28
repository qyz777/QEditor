Pod::Spec.new do |spec|
  spec.name         = "DispatchQueuePool"
  spec.version      = "0.0.1"
  spec.summary      = "A swift copy project of YYDispatchQueuePool."
  spec.homepage     = "http://www.qyizhong.cn"
  spec.license      = "MIT"
  spec.author             = { "Q YiZhong" => "178159283@qq.com" }
  spec.source       = { :git => "", :tag => "#{spec.version}" }
  spec.source_files  = "Classes", "Classes/**/*.swift"
  spec.exclude_files = "Classes/Exclude"
end
