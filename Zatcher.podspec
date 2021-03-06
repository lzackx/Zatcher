#
# Be sure to run `pod lib lint Zatcher.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Zatcher'
  s.version          = '1.0.0'
  s.summary          = 'A simple logger'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
A simple logger
                       DESC

  s.homepage         = 'https://github.com/lzackx/Zatcher'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'lzackx' => 'lzackx@lzackx.com' }
  s.source           = { :git => 'https://github.com/lzackx/Zatcher.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'
	s.static_framework = true
  s.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
	s.default_subspec		= "Core"
	
	s.subspec "Core" do |ss|
		ss.source_files = [
		'Zatcher/Classes/*.[h,m]',
		'Zatcher/Classes/RenderMonitor/**/*.[h,m]'
		]
		ss.dependency 'PLCrashReporter', '~> 1.8'
	end
	
	s.subspec "OrderGenerator" do |ss|
		ss.source_files = 'Zatcher/Classes/OrderGenerator/**/*.[h,m]'
	end
	
end
