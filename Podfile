platform :ios, "9.0"
use_frameworks!

#sources
source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/worldline-spain/t21_pods-specs_ios.git'

#IMPORTANT: Change the name of the workspace according to your workspace for the project.
workspace 'T21HTTPRequester'
project 'T21HTTPRequester'

target 'T21HTTPRequester' do
    pod 'Moya', '~> 9.0'
    pod 'T21LoggerSwift'
    pod 'T21Mapping'
end

target 'T21HTTPRequesterTests' do
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '4.0'
            if config.name == 'devel' || config.name == 'Debug'
                config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= ['$(inherited)', 'DEBUG=1']
                config.build_settings['OTHER_SWIFT_FLAGS'] ||= ['$(inherited)','-DDEBUG']
            end
        end
    end
end
