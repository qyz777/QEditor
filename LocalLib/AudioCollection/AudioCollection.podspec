Pod::Spec.new do |spec|
  spec.name         = "AudioCollection"
  spec.version      = "0.0.1"
  spec.summary      = "collections of audio."

  spec.homepage     = "http://www.qyizhong.cn"

  spec.license      = "MIT"

  spec.author             = { "Q YiZhong" => "178159283@qq.com" }

  spec.source       = { :git => "", :tag => "#{spec.version}" }
  spec.platform     = :ios, "11.0"
  spec.source_files  = "Classes", "Classes/**/*.swift"
  spec.exclude_files = "Classes/Exclude"
  spec.resource_bundles = {
    "AudioCollection" => ["Resource/**/*{xcassets}"]
  }

  spec.dependency "TableViewAdapter"
  spec.dependency "SnapKit"

end
