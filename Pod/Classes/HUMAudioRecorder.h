//
//  HUMAudioRecorder.h
//  HUMAudioRecorder
//
//  Created by Colin Humber on 2015-07-25.
//  Copyright (c) 2015 Colin Humber. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, HUMAudioRecorderState) {
    /**
     *  No recording, listening, or playback activity is occurring.
     */
    HUMAudioRecorderStateIdle = 0,
    
    /**
     *  The recorder is listening to ambient noises but is not recording.
     */
    HUMAudioRecorderStateListening,
    
    /**
     *  Recording is currently in progress and will be saved to the specified audioFileURL.
     */
    HUMAudioRecorderStateRecording,
    
    /**
     *  Audio saved to the audioFileURL is being played back.
     */
    HUMAudioRecorderStatePlayback
};

typedef void(^HUMAudioRecorderLevelBlock)(float level);


@protocol HUMAudioRecorderDelegate;

@interface HUMAudioRecorder : NSObject

/**
 *  The delegate for the audio recorder.
 */
@property (nonatomic, weak) id<HUMAudioRecorderDelegate> delegate;

/**
 *  Flag indicating whether listening to environmental sounds is enabled. If NO, stopping recording or playback will
 *  transition to the @c HUMAudioRecorderStateIdle state. Otherwise, stopping recording or playback will transition to
 *  the @c HUMAudioRecorderStateListening state. The default is YES.
 */
@property (nonatomic, assign, getter=isListeningEnabled) BOOL listeningEnabled;

/**
 *  A Boolean value that indicates whether audio-level metering is enabled. The default is NO.
 */
@property (nonatomic, assign, getter=isMeteringEnabled) BOOL meteringEnabled;

/**
 *  The max duration, in seconds, the recorder should record for. If zero or a negative number, the recorder will record indefinitely.
 */
@property (nonatomic, assign) NSTimeInterval maxRecordingDuration;

/**
 *  The data stream for the audio content stored at the @c audioFileURL.
 */
@property (nonatomic, readonly) NSData *audioData;

/**
 *  The current state. See @c HUMAudioRecorderState for valid states. This property is KVO-compliant.
 */
@property (nonatomic, readonly) HUMAudioRecorderState state;

/**
 *  The file URL where the audio recording is stored. This must be a local file URL.
 */
@property (nonatomic, readonly) NSURL *audioFileURL;

/**
 *  The time, in seconds, since the beginning of the recording or playback. This property is KVO-compliant.
 */
@property (nonatomic, readonly) NSTimeInterval currentTime;

/**
 *  The total duration, in seconds, of the audio file.
 */
@property (nonatomic, readonly) NSTimeInterval duration;

/**
 *  A block to execute when the environmental power levels change. This will only fire if @c listeningEnabled is YES.
 */
@property (nonatomic, copy) HUMAudioRecorderLevelBlock environmentLevelsHandler;

/**
 *  A block to execute when the recording or playback power levels change, depending on the current state.
 */
@property (nonatomic, copy) HUMAudioRecorderLevelBlock recorderPlaybackLevelsHandler;


/**
 *  Creates a new HUMAudioRecorder instance configured to record to the provided URL with the specified settings.
 *
 *  @param URL      The URL on the local file system where the audio will be recorded.
 *  @param settings Settings for the recording session. @see For information on the settings available for an audio recorder, see [AV Foundation Audio Settings Constants](https://developer.apple.com/library/mac/documentation/AVFoundation/Reference/AVFoundationAudioSettings_Constants).
 *
 *  @return An HUMAudioRecorder instance.
 */
- (instancetype)initWithURL:(NSURL *)URL settings:(NSDictionary *)settings;

/**
 *  Begins listening to environmental noise and stops the audio recorder or player, if they are active. If the delegate implements the -audioRecorder:didUpdateEnvironmentAveragePower:, decibel updates will be sent
 *  through the delegate method.
 */
- (void)startListening;

/**
 *  Stops listening to environmental noises. No further delegate callbacks to -audioRecorder:didUpdateEnvironmentAveragePower: will fire.
 */
- (void)stopListening;

/**
 *  Begins recording and stops the listener and player, if they are active. If the delegate implements the -audioRecorder:didUpdateAveragePower:, decibel updates will be sent
 *  through the delegate method.
 */
- (void)startRecording;

/**
 *  Stops recording and transitions back to the HUMAudioRecorderStateListening state, if @c listeningEnabled is YES. Otherwise, the recorder will transition
 *  to the HUMAudioRecorderStateIdle state. No further delegate callbacks to -audioRecorder:didUpdateAveragePower: will fire.
 */
- (void)stopRecording;

/**
 *  Begins playback of the recorded audio and stops the listener and recorder, if they are active. If the delegate implements the -audioRecorder:didUpdateAveragePower:, decibel updates will be sent
 *  through the delegate method.
 */
- (void)startPlayback;

/**
 *  Stops playback and transitions back to the HUMAudioRecorderStateListening state. No further delegate callbacks to -audioRecorder:didUpdateAveragePower: will fire.
 */
- (void)stopPlayback;

/**
 *  Completes the existing recording/playback session. Deactivates the app's audio session transitions to the idle state. This should be called prior to using
 *  the recorded audio to ensure the recorder, listener, and players are completely shut down and all files closed.
 */
- (void)completeSession;

/**
 *  Deletes the recording at the @c audioFileURL. Returns YES on success, NO otherwise.
 */
- (BOOL)deleteRecording;

@end

/**
 *  The delegate of the HUMAudioRecorder. All methods are optional and provide details on the current recording or playback state.
 */
@protocol HUMAudioRecorderDelegate <NSObject>
@optional

/**
 Tells the delegate that listening has stopped.

 @param recorder   The recorder instance that is notifying the delegate of the event.
 @param successful YES on successful completion of recording; NO if recording stopped because of an audio encoding error.
 */
- (void)audioRecorderDidFinishListening:(HUMAudioRecorder *)recorder successfully:(BOOL)successful;

/**
 Tells the delegate that recording has stopped.
 
 @param recorder   The recorder instance that is notifying the delegate of the event.
 @param successful YES on successful completion of recording; NO if recording stopped because of an audio encoding error.
 */
- (void)audioRecorderDidFinishRecording:(HUMAudioRecorder *)recorder successfully:(BOOL)successful;

/**
 Tells the delegate that listening has stopped.
 
 @param recorder   The recorder instance that is notifying the delegate of the event.
 @param successful YES on successful completion of playback; NO if playback stopped because the system could not decode the audio data.
 */
- (void)audioRecorderDidFinishPlayback:(HUMAudioRecorder *)recorder successfully:(BOOL)successful;

/**
 *  Tells the delegate that a recording error has occured.
 *
 *  @param error The recording error that occured.
 */
- (void)audioRecorderDidFailRecording:(HUMAudioRecorder *)recorder error:(NSError *)error;

/**
 *  Tells the delegate that a playback error has occured.
 *
 *  @param error The playback error that occured.
 */
- (void)audioRecorderDidFailPlayback:(HUMAudioRecorder *)recorder error:(NSError *)error;


@end
