#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_flurry_sdk.podspec` to validate before publishing.
#

sdkVersion = '12.4.0'

Pod::Spec.new do |s|
  s.name             = 'flutter_flurry_sdk'
  s.version          = '0.0.1'
  s.summary          = 'A new flutter plugin project.'
  s.description      = <<-DESC
A new flutter plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.dependency 'Flurry-iOS-SDK/FlurrySDK', "~> #{sdkVersion}"
  s.dependency 'Flurry-iOS-SDK/FlurryMessaging', "~> #{sdkVersion}"
  s.dependency 'Flurry-iOS-SDK/FlurryConfig', "~> #{sdkVersion}"
  s.platform = :ios, '10.0'
  s.static_framework = true

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386 arm64' }
end
