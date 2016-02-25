//
//  BackgroundRunTask.m
//  DataEyeAlarm
//
//  Created by xqwang on 16/2/4.
//  Copyright © 2016年 DataEye. All rights reserved.
//

#import "BackgroundRunTask.h"
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface BackgroundRunTask ()

@property(nonatomic, strong)NSTimer* bgTaskTimer;
@property(nonatomic, strong)NSTimer* taskTimer;
@property(nonatomic, assign)NSUInteger taskTimeInterval;
@property(nonatomic, assign)UIBackgroundTaskIdentifier task;
@property(nonatomic, strong)AVAudioPlayer* player;

@end

@implementation BackgroundRunTask

@synthesize delegate;
@synthesize bgTaskTimer;
@synthesize taskTimer;
@synthesize taskTimeInterval;
@synthesize task;
@synthesize player;

-(BackgroundRunTask*)initWithTaskRunInterval:(NSUInteger)interval
{
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resumeForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
        
        [self setTaskTimeInterval:interval];
        [self backgroundSlientMusic];
        NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:@"MMPSilence" ofType:@"wav"];
        NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:soundFilePath];
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
        [player prepareToPlay];
        [player setVolume:0.0f];
    }
    return self;
}

-(void)stop
{
    [self stopBackgroundTask];
}

-(void)enterBackground
{
    [self applyBackgroundTask];
}

-(void)resumeForeground
{
    [self stop];
}

-(void)applyBackgroundTask
{
    UIApplication* application = [UIApplication sharedApplication];
    task = [application beginBackgroundTaskWithExpirationHandler:^{
        [self stopBackgroundTask];
    }];
    bgTaskTimer = [NSTimer scheduledTimerWithTimeInterval:20.0f target:self selector:@selector(onTick:) userInfo:nil repeats:YES];
    taskTimer = [NSTimer scheduledTimerWithTimeInterval:taskTimeInterval target:self selector:@selector(onTick:) userInfo:nil repeats:YES];
}

-(void)stopBackgroundTask
{
    [[UIApplication sharedApplication] endBackgroundTask:task];
    task = UIBackgroundTaskInvalid;
    [bgTaskTimer invalidate];
    bgTaskTimer = nil;
    [taskTimer invalidate];
    taskTimer = nil;
}

-(void)onTick:(NSTimer*)timer
{
    if ([timer isEqual:taskTimer]) {
        if (delegate) {
            [delegate performSelector:@selector(backgroundTaskRun)];
        }
    }else if([timer isEqual:bgTaskTimer]){
        [player play];
        UIApplication* application = [UIApplication sharedApplication];
        if ([application backgroundTimeRemaining] <= 20) {
            [self stopBackgroundTask];
            [self applyBackgroundTask];
        }
    }
}

- (void)backgroundSlientMusic
{
    // Initialize audio session
    AudioSessionInitialize
    (
     NULL,	// Use NULL to use the default (main) run loop.
     NULL,	// Use NULL to use the default run loop mode.
     NULL,	// A reference to your interruption listener callback function.
     // See “Responding to Audio Session Interruptions” in Apple's "Audio Session Programming Guide" for a description of how to write
     // and use an interruption callback function.
     NULL	// Data you intend to be passed to your interruption listener callback function when the audio session object invokes it.
     );
    
    // Activate audio session
    OSStatus activationResult = 0;
    activationResult		  = AudioSessionSetActive(true);
    
    if (activationResult)
    {
        //		MMPDLog(@"AudioSession is active");
    }
    
    // Set up audio session category to kAudioSessionCategory_MediaPlayback.
    // While playing sounds using this session category at least every 10 seconds, the iPhone doesn't go to sleep.
    UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;	// Defines a new variable of type UInt32 and initializes it with the identifier
    // for the category you want to apply to the audio session.
    AudioSessionSetProperty
    (
     kAudioSessionProperty_AudioCategory,	// The identifier, or key, for the audio session property you want to set.
     sizeof(sessionCategory),				// The size, in bytes, of the property value that you are applying.
     &sessionCategory						// The category you want to apply to the audio session.
     );
    
    // Set up audio session playback mixing behavior.
    // kAudioSessionCategory_MediaPlayback usually prevents playback mixing, so we allow it here. This way, we don't get in the way of other sound playback in an application.
    // This property has a value of false (0) by default. When the audio session category changes, such as during an interruption, the value of this property reverts to false.
    // To regain mixing behavior you must then set this property again.
    
    // Always check to see if setting this property succeeds or fails, and react appropriately; behavior may change in future releases of iPhone OS.
    OSStatus propertySetError = 0;
    UInt32 allowMixing		  = true;
    
    propertySetError = AudioSessionSetProperty
    (
     kAudioSessionProperty_OverrideCategoryMixWithOthers,	// The identifier, or key, for the audio session property you want to set.
     sizeof(allowMixing),									// The size, in bytes, of the property value that you are applying.
     &allowMixing											// The value to apply to the property.
     );
    
    if (propertySetError)
    {
        //		MMPALog(@"Error setting kAudioSessionProperty_OverrideCategoryMixWithOthers: %ld", propertySetError);
    }
}

@end
