# HUMAudioRecorder

[![CI Status](http://img.shields.io/travis/Colin Humber/HUMAudioRecorder.svg?style=flat)](https://travis-ci.org/Colin Humber/HUMAudioRecorder)
[![Version](https://img.shields.io/cocoapods/v/HUMAudioRecorder.svg?style=flat)](http://cocoapods.org/pods/HUMAudioRecorder)
[![License](https://img.shields.io/cocoapods/l/HUMAudioRecorder.svg?style=flat)](http://cocoapods.org/pods/HUMAudioRecorder)
[![Platform](https://img.shields.io/cocoapods/p/HUMAudioRecorder.svg?style=flat)](http://cocoapods.org/pods/HUMAudioRecorder)

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

HUMAudioRecorder is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "HUMAudioRecorder"
```

## Usage

Using HUMAudioRecorder is super easy! Just make a URL where you want the file to live, setup your audio session settings, and create a new HUMAudioRecorder instance.

For a list of AVFoundation settings, go [here](https://developer.apple.com/library/mac/documentation/AVFoundation/Reference/AVFoundationAudioSettings_Constants/).

```objc
NSURL *url = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.m4a", [NSUUID UUID].UUIDString]]];

NSDictionary *settings = @{ AVFormatIDKey : @(kAudioFormatMPEG4AAC),
                            AVSampleRateKey : @44100,
                            AVNumberOfChannelsKey : @1,
                            AVEncoderAudioQualityKey : @(AVAudioQualityHigh)};

HUMAudioRecorder *audioRecorder = [[HUMAudioRecorder alloc] initWithURL:url settings:settings];
```

The header is well documented, so check it out for a list of properties and methods. There are well defined states that can be used when this is used as the backing recorder/player for your UI.

## Author

Colin Humber, colinhumber@gmail.com

## License

HUMAudioRecorder is available under the MIT license. See the LICENSE file for more info.
