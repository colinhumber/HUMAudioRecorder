#
# Be sure to run `pod lib lint HUMAudioRecorder.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "HUMAudioRecorder"
  s.version          = "0.1.0"
  s.summary          = "A neat class that handles audio recording and playback."
  s.description      = <<-DESC
                       An optional longer description of HUMAudioRecorder

                       * Markdown format.
                       * Don't worry about the indent, we strip it!
                       DESC
  s.homepage         = "https://github.com/colinhumber/HUMAudioRecorder"
  s.license          = 'MIT'
  s.author           = { "Colin Humber" => "colinhumber@gmail.com" }
  s.source           = { :git => "https://github.com/colinhumber/HUMAudioRecorder.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/colinhumber'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'

   s.frameworks = 'AVFoundation'
end
