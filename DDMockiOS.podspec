#
# Be sure to run `pod lib lint DDMockiOS.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |spec|
  spec.name             = 'DDMockiOS'
  spec.version          = '0.1.5'
  spec.summary          = 'Deloitte Digital simple network mocking library for iOS'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

#  spec.description      = <<-DESC
#  Deloitte Digital simple network mocking library for iOS
#                       DESC

  spec.homepage         = 'https://github.com/DeloitteDigitalAPAC/ddmock-ios'
  # spec.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  spec.license          = { :type => 'MIT', :file => 'LICENSE' }
  spec.author           = 'Deloitte Digital Asia Pacific'
  spec.source           = { :git => "https://github.com/DeloitteDigitalAPAC/ddmock-ios.git", :tag => 'v' + spec.version.to_s }

  spec.ios.deployment_target = '11.0'

  spec.source_files = 'DDMockiOS'

  spec.preserve_paths = [
      'init-mocks.py',
    ]

  spec.swift_version = '5'
  spec.static_framework = true
end
