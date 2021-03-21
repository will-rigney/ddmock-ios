#
# Be sure to run `pod lib lint DDMockiOS.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'DDMockiOS'
  s.version          = '0.1.5'
  s.summary          = 'Deloitte Digital simple network mocking library for iOS'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

#  s.description      = <<-DESC
#  Deloitte Digital simple network mocking library for iOS
#                       DESC

  s.homepage         = 'https://github.com/DeloitteDigitalAPAC/ddmock-ios'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = 'Deloitte Digital Asia Pacific'
  s.source           = { :git => "https://github.com/DeloitteDigitalAPAC/ddmock-ios.git", :tag => 'v' + s.version.to_s }

  s.ios.deployment_target = '11.0'

  s.source_files = 'DDMockiOS'

  s.preserve_paths = [
      'init-mocks.py',
    ]

  s.swift_version = '5'
  s.static_framework = true
end
