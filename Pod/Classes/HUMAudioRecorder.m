//
//  HUMAudioRecorder.m
//  HUMAudioRecorder
//
//  Created by Colin Humber on 2015-07-25.
//  Copyright (c) 2015 Colin Humber. All rights reserved.
//

#import "HUMAudioRecorder.h"

@import AVFoundation;

@interface HUMAudioRecorder () <AVAudioPlayerDelegate, AVAudioRecorderDelegate>
@property (nonatomic, strong) NSDictionary *settings;
@property (nonatomic, strong) AVAudioRecorder *listener;
@property (nonatomic, strong) AVAudioRecorder *recorder;
@property (nonatomic, strong) AVAudioPlayer *player;
@property (nonatomic, strong) NSURL *audioFileURL;
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, assign) NSTimeInterval currentTime;
@end


@implementation HUMAudioRecorder

- (instancetype)initWithURL:(NSURL *)URL settings:(NSDictionary *)settings {
    self = [super init];
    
    if (self) {
        NSParameterAssert(URL != nil);
        NSAssert(URL.isFileURL, @"The provided URL must be a file URL");
        NSParameterAssert(settings != nil);
        
        _audioFileURL = URL;
        _settings = settings;
        _listeningEnabled = YES;
        _meteringEnabled = NO;
    }
    
    return self;
}


#pragma mark - Public Methods

- (void)startListening {
    if ([self canTransitionToState:HUMAudioRecorderStateListening]) {
        [self transitionToState:HUMAudioRecorderStateListening];
    }
    else {
        [self transitionToState:HUMAudioRecorderStateIdle];
    }
}

- (void)stopListening {
    if ([self canTransitionToState:HUMAudioRecorderStateIdle]) {
        [self transitionToState:HUMAudioRecorderStateIdle];
    }
}

- (void)startRecording {
    if ([self canTransitionToState:HUMAudioRecorderStateRecording]) {
        [self transitionToState:HUMAudioRecorderStateRecording];
    }
}

- (void)stopRecording {
    if ([self canTransitionToState:HUMAudioRecorderStateListening]) {
        [self transitionToState:HUMAudioRecorderStateListening];
    }
    else {
        [self transitionToState:HUMAudioRecorderStateIdle];
    }
}

- (void)startPlayback {
    if ([self canTransitionToState:HUMAudioRecorderStatePlayback]) {
        [self transitionToState:HUMAudioRecorderStatePlayback];
    }
    else {
        if ([self.delegate respondsToSelector:@selector(audioRecorderDidFailPlaybackWithError:)]) {
            NSError *error = [NSError errorWithDomain:@"com.showbie.showbieapp"
                                                 code:kAudioFileInvalidFileError
                                             userInfo:@{ NSLocalizedDescriptionKey : NSLocalizedString(@"Unable to begin playback. The file could not be found.", @"error text") }];
            [self.delegate audioRecorderDidFailPlaybackWithError:error];
        }

        NSLog(@"Unable to playback audio at %@. The file could not be found.", self.audioFileURL);
        [self transitionToState:HUMAudioRecorderStateIdle];
    }
}

- (void)stopPlayback {
    if ([self canTransitionToState:HUMAudioRecorderStateListening]) {
        [self transitionToState:HUMAudioRecorderStateListening];
    }
    else {
        [self transitionToState:HUMAudioRecorderStateIdle];
    }
}

- (void)completeSession {
    [self.displayLink invalidate];
    self.displayLink = nil;
    
    [self transitionToState:HUMAudioRecorderStateIdle];
}

- (BOOL)deleteRecording {
    return [self.recorder deleteRecording];
}


#pragma mark - Properties

- (void)setMeteringEnabled:(BOOL)meteringEnabled {
    if (_meteringEnabled != meteringEnabled) {
        _meteringEnabled = meteringEnabled;
        self.recorder.meteringEnabled = meteringEnabled;
        self.listener.meteringEnabled = meteringEnabled;
    }
}

- (NSData *)audioData {
    return [NSData dataWithContentsOfURL:self.audioFileURL];
}

- (NSTimeInterval)duration {
    AVURLAsset *audioAsset = [AVURLAsset URLAssetWithURL:self.audioFileURL options:nil];
    return CMTimeGetSeconds(audioAsset.duration);
}


#pragma mark - State Management

- (BOOL)canTransitionToState:(HUMAudioRecorderState)state {
    switch (state) {
        case HUMAudioRecorderStateIdle:
            return YES;
            
        case HUMAudioRecorderStateListening:
            return self.listeningEnabled;

        case HUMAudioRecorderStateRecording:
            return YES;

        case HUMAudioRecorderStatePlayback:
            return [[NSFileManager defaultManager] fileExistsAtPath:self.audioFileURL.path];

        default:
            break;
    }
}

- (void)transitionToState:(HUMAudioRecorderState)state {
    switch (state) {
        case HUMAudioRecorderStateListening: {
            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryRecord error:nil];
            [[AVAudioSession sharedInstance] setActive:YES error:nil];
            if (self.recorder.recording) {
                [self.recorder stop];
            }
            
            if (self.player.playing) {
                [self.player stop];
            }
            
            [self.listener record];
            
            if (self.meteringEnabled) {
                [self enableMetering];
            }
            
            break;
        }
            
        case HUMAudioRecorderStateRecording: {
            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryRecord error:nil];
            [[AVAudioSession sharedInstance] setActive:YES error:nil];

            [self destroyPlayer];

            if (self.listener.recording) {
                [self.listener stop];
            }
            
            if (self.maxRecordingDuration > 0) {
                [self.recorder recordForDuration:self.maxRecordingDuration];
            }
            else {
                [self.recorder record];
            }
            
            if (self.meteringEnabled) {
                [self enableMetering];
            }

            break;
        }
            
        case HUMAudioRecorderStatePlayback: {
            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
            [[AVAudioSession sharedInstance] setActive:YES error:nil];

            if (self.recorder.recording) {
                [self.recorder stop];
            }
            
            if (self.listener.recording) {
                [self.listener stop];
            }
            
            if (!self.player) {
                self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:self.audioFileURL error:nil];
                self.player.delegate = self;
                self.player.meteringEnabled = self.meteringEnabled;
            }
            
            [self.player play];
            
            if (self.meteringEnabled) {
                [self enableMetering];
            }

            break;
        }
            
        case HUMAudioRecorderStateIdle:
        default: {
            if (self.listener.recording) {
                [self.listener stop];
            }

            if (self.recorder.recording) {
                [self.recorder stop];
            }
            
            [self destroyPlayer];
            
            [self.displayLink invalidate];
            self.displayLink = nil;
            
            [[AVAudioSession sharedInstance] setActive:NO error:nil];
            break;
        }
    }
    
//    self.displayLink.paused = (state == HUMAudioRecorderStateIdle);

    [self willChangeValueForKey:@"state"];
    _state = state;
    [self didChangeValueForKey:@"state"];
}


#pragma mark - Timers and Callbacks

- (void)enableMetering {
    if (!self.displayLink) {
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateMeters:)];
        [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    }
}

- (void)updateMeters:(CADisplayLink *)displayLink {
    switch (self.state) {
        case HUMAudioRecorderStateListening:
            self.currentTime = 0;
            
            if (self.environmentLevelsHandler) {
                [self.listener updateMeters];
                self.environmentLevelsHandler([self.listener averagePowerForChannel:0]);
            }
            
            break;
        
        case HUMAudioRecorderStateRecording:
            self.currentTime = self.recorder.currentTime;

            if (self.recorderPlaybackLevelsHandler) {
                [self.recorder updateMeters];
                self.recorderPlaybackLevelsHandler([self.recorder averagePowerForChannel:0]);
            }

            break;
        
        case HUMAudioRecorderStatePlayback:
            self.currentTime = self.player.currentTime;

            if (self.recorderPlaybackLevelsHandler) {
                [self.player updateMeters];
                self.recorderPlaybackLevelsHandler([self.player averagePowerForChannel:0]);
            }

            break;
        
        case HUMAudioRecorderStateIdle:
        default:
            self.currentTime = 0;
            break;
    }
}


#pragma mark - Recorders and Player

- (AVAudioRecorder *)listener {
    if (!_listener) {
        _listener = [[AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPath:@"/dev/null"] settings:self.settings error:nil];
        _listener.delegate = self;
        [_listener prepareToRecord];
        _listener.meteringEnabled = self.meteringEnabled;
    }
    
    return _listener;
}

- (AVAudioRecorder *)recorder {
    if (!_recorder) {
        NSError *error = nil;
        _recorder = [[AVAudioRecorder alloc] initWithURL:self.audioFileURL settings:self.settings error:&error];
        _recorder.delegate = self;
        [_recorder prepareToRecord];
        _recorder.meteringEnabled = self.meteringEnabled;
        
        if (error && [self.delegate respondsToSelector:@selector(audioRecorderDidFailRecordingWithError:)]) {
            [self.delegate audioRecorderDidFailRecordingWithError:error];
        }
    }
    
    return _recorder;
}

- (void)destroyPlayer {
    if (self.player.playing) {
        [self.player stop];
    }
    
    self.player = nil;
}


#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [self transitionToState:HUMAudioRecorderStateListening];
}

@end
