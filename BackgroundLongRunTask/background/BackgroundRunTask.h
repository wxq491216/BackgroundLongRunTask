//
//  BackgroundRunTask.h
//  DataEyeAlarm
//
//  Created by xqwang on 16/2/4.
//  Copyright © 2016年 DataEye. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BackgroundRunTaskDelegate <NSObject>

-(void)backgroundTaskRun;

@end

@interface BackgroundRunTask : NSObject

@property(nonatomic, weak)id<BackgroundRunTaskDelegate> delegate;

-(BackgroundRunTask*)initWithTaskRunInterval:(NSUInteger)interval;

@end
