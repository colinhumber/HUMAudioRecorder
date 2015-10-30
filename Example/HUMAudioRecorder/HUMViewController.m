//
//  HUMViewController.m
//  HUMAudioRecorder
//
//  Created by Colin Humber on 07/26/2015.
//  Copyright (c) 2015 Colin Humber. All rights reserved.
//

#import "HUMViewController.h"
#import <HUMAudioRecorder/HUMAudioRecorder.h>

@import AVFoundation;

@interface HUMViewController () <HUMAudioRecorderDelegate>
@property (nonatomic, strong) HUMAudioRecorder *audioRecorder;
@property (nonatomic, weak) IBOutlet UILabel *soundURLLabel;
@property (nonatomic, weak) IBOutlet UILabel *meterLabel;
@property (nonatomic, weak) IBOutlet UILabel *stateLabel;
@property (nonatomic, weak) IBOutlet UIButton *listeningButton;
@property (nonatomic, weak) IBOutlet UIButton *recordingButton;
@property (nonatomic, weak) IBOutlet UIButton *playbackButton;
@end

@implementation HUMViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionMixWithOthers error:nil];
//    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated {
    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
        NSURL *url = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.m4a", [NSUUID UUID].UUIDString]]];
        self.soundURLLabel.text = url.path;
        
        self.audioRecorder = [[HUMAudioRecorder alloc] initWithURL:url settings:@{ AVFormatIDKey : @(kAudioFormatMPEG4AAC),
                                                                                   AVSampleRateKey : @44100,
                                                                                   AVNumberOfChannelsKey : @1,
                                                                                   AVEncoderAudioQualityKey : @(AVAudioQualityHigh)}];
        self.audioRecorder.delegate = self;
        [self.audioRecorder addObserver:self forKeyPath:NSStringFromSelector(@selector(state)) options:0 context:NULL];
        
        __weak typeof(self)weakSelf = self;

        self.audioRecorder.environmentLevelsHandler = ^(float level) {
            weakSelf.meterLabel.text = @(level).stringValue;
        };
        
        self.audioRecorder.recorderPlaybackLevelsHandler = ^(float level) {
            weakSelf.meterLabel.text = @(level).stringValue;
        };
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)listen:(UIButton *)sender {
    if (self.audioRecorder.state != HUMAudioRecorderStateListening) {
        [self.audioRecorder startListening];
    }
    else {
        [self.audioRecorder stopListening];
    }
}

- (IBAction)record:(UIButton *)sender {
    if (self.audioRecorder.state != HUMAudioRecorderStateRecording) {
        [self.audioRecorder startRecording];
    }
    else {
        [self.audioRecorder stopRecording];
    }
}

- (IBAction)play:(UIButton *)sender {
    if (self.audioRecorder.state != HUMAudioRecorderStatePlayback) {
        [self.audioRecorder startPlayback];
    }
    else {
        [self.audioRecorder stopPlayback];
    }
}

- (void)updateUIForCurrentState {
    switch (self.audioRecorder.state) {
        case HUMAudioRecorderStateIdle: {
            self.stateLabel.text = @"Idle";
            [self.playbackButton setTitle:@"Start Playback" forState:UIControlStateNormal];
            [self.recordingButton setTitle:@"Start Recording" forState:UIControlStateNormal];
            [self.listeningButton setTitle:@"Start Listening" forState:UIControlStateNormal];

            break;
        }

        case HUMAudioRecorderStateListening: {
            self.stateLabel.text = @"Listening";
            [self.playbackButton setTitle:@"Start Playback" forState:UIControlStateNormal];
            [self.recordingButton setTitle:@"Start Recording" forState:UIControlStateNormal];
            [self.listeningButton setTitle:@"Stop Listening" forState:UIControlStateNormal];

            break;
        }
        case HUMAudioRecorderStateRecording: {
            self.stateLabel.text = @"Recording";
            [self.playbackButton setTitle:@"Start Playback" forState:UIControlStateNormal];
            [self.recordingButton setTitle:@"Stop Recording" forState:UIControlStateNormal];
            [self.listeningButton setTitle:@"Start Listening" forState:UIControlStateNormal];

            break;
        }
        case HUMAudioRecorderStatePlayback: {
            self.stateLabel.text = @"Playing";
            [self.playbackButton setTitle:@"Stop Playback" forState:UIControlStateNormal];
            [self.recordingButton setTitle:@"Start Recording" forState:UIControlStateNormal];
            [self.listeningButton setTitle:@"Start Listening" forState:UIControlStateNormal];

            break;
        }
            
        default: {
            self.stateLabel.text = @"Unknown";
            [self.playbackButton setTitle:@"Start Playback" forState:UIControlStateNormal];
            [self.recordingButton setTitle:@"Start Recording" forState:UIControlStateNormal];
            [self.listeningButton setTitle:@"Start Listening" forState:UIControlStateNormal];

            break;
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(state))]) {
        [self updateUIForCurrentState];
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end
