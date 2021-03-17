#
# Be sure to run `pod lib lint TWMedia.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'TWMedia'
  s.version          = '0.0.1'
  s.summary          = 'TWMedia.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = 'TWMedia tool.'

  s.homepage         = 'https://github.com/tanwang11/TWMedia'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'tanwang11' => 'aihy@linrunwc.com' }
  s.source           = { :git => 'https://github.com/tanwang11/TWMedia.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'

  s.source_files = 'Example/TWMedia/Classes/*.{h,m}'
  
  s.resource_bundles = {
      'TWMedia' => ['Example/TWMedia/Classes/*.bundle']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
  
  s.frameworks = 'UIKit', 'Photos', 'MobileCoreServices'
  
  s.dependency 'TWImageBrower'
  s.dependency 'TWUI'
  s.dependency 'TWImageBrower'
  s.dependency 'Masonry'
  s.dependency 'TWFoundation'
  s.dependency 'TZImagePickerController'
  s.dependency 'SKFCamera'
  s.dependency 'ReactiveObjC'
  
end
