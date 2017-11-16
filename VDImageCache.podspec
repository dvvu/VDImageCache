#
# Be sure to run `pod lib lint VDImageCache.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'VDImageCache'
  s.version          = '0.1.0'
  s.summary          = 'VDImageCache can help you cache images'

  s.homepage         = 'https://github.com/dvvu/VDImageCache'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'dvvu' => 'doanvanvu9992@gmail.com' }
  s.source           = { :git => 'https://github.com/dvvu/VDImageCache.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'VDImageCache/Classes/**/*'
  
#  s.resource_bundles = {
#    'VDImageCache' => ['VDImageCache/Assets/*.png']
#}

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
