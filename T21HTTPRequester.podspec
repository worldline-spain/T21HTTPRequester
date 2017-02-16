
Pod::Spec.new do |s|

  s.name         = "T21HTTPRequester"
  s.version      = "1.0.0"
  s.summary      = "T21HTTPRequester"
  s.author    = "Eloi Guzman Ceron"
  s.platform     = :ios
  s.ios.deployment_target = "8.0"
  s.source       = { :git => "https://github.com/worldline-spain/T21HTTPRequester.git", :tag => "1.0.0" }
  s.source_files  = "Classes", "src/**/*.{swift}"
  s.framework  = "Foundation"
  s.requires_arc = true

  s.dependency "T21Mapping"
  s.dependency "T21LoggerSwift"
  s.dependency "Moya"

end
