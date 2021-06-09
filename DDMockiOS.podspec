#
# Be sure to run `pod lib lint DDMockiOS.podspec' to ensure this is a
# valid spec before submitting.
#
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |spec|
  spec.name             = 'DDMockiOS'
  spec.version          = '2.0'
  spec.summary          = 'Deloitte Digital simple network mocking library for iOS'

  spec.description      = 'Deloitte Digital simple network mocking library for iOS'

  spec.homepage         = 'https://github.com/DeloitteDigitalAPAC/ddmock-ios'
  spec.license          = { :type => 'MIT', :file => 'LICENSE' }
  spec.author           = 'Deloitte Digital Asia Pacific'
  spec.source           = { :git => "https://github.com/will-rigney/ddmock-ios.git", :tag => 'v' + spec.version.to_s }

  spec.ios.deployment_target = '11.0'

  spec.source_files = 'DDMockiOS'

  spec.preserve_paths = [
    'Generate/ddmock.py',
    'Resources/general.json',
    'Resources/root.json'
  ]

  spec.swift_version = '5'
  spec.static_framework = true
end
