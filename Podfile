# Uncomment this line to define a global platform for your project
platform :ios, '9.0'
use_frameworks!

target 'AcmeHealth' do

  # Pods for AcmeHealth 
  pod 'OktaAuth'
  pod 'Alamofire'
  pod 'JSQMessagesViewController', :git => 'https://github.com/jessesquires/JSQMessagesViewController.git', :branch => 'develop'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
          config.build_settings['ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES'] = 'NO'              
      end
  end
end