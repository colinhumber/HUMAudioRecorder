#
# Be sure to run `pod lib lint HUMAudioRecorder.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
    s.name             = "HUMAudioRecorder"
    s.version          = "0.1.0"
    s.summary          = "Drop in utility for recording and playing back audio, as well as listening to ambient sounds."

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!  
    s.description      = <<-DESC
            A simple utility for recording, playing back, and listening to ambient audio, when metering is needed.
            Provides a simple wrapper around AVAudioRecorder and AVAudioPlayer and manages most of the standard
            tasks needed for audio recording and playback.
                       DESC

    s.homepage         = "https://github.com/colinhumber/HUMAudioRecorder"
    s.license          = 'MIT'
    s.author           = { "Colin Humber" => "colinhumber@gmail.com" }
    s.source           = { :git => "https://github.com/colinhumber/HUMAudioRecorder.git", :tag => s.version.to_s }
    s.social_media_url = 'https://twitter.com/colinhumber'

    s.platform     = :ios, '7.0'
    s.requires_arc = true

    s.source_files = 'Pod/Classes/**/*'

    s.public_header_files = 'Pod/Classes/**/*.h'
    s.frameworks = 'AVFoundation'
end
