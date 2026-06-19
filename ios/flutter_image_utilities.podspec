#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_image_utilities.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_image_utilities'
  s.version          = '2.3.0'
  s.summary          = 'Image file related utilities for iOS.'
  s.description      = <<-DESC
A Flutter plugin for saving an image as JPEG with the specified quality and size and for getting image properties on iOS.
                       DESC
  s.homepage         = 'https://github.com/kineapps/flutter_image_utilities'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'KineApps' => 'https://github.com/kineapps' }
  s.source           = { :path => '.' }
  s.source_files = 'flutter_image_utilities/Sources/flutter_image_utilities/**/*.swift'
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'

  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.9'
end
