//
//  YTAudioEngine.h
//  YuTone
//
//  Created by Matt on 2/1/14.
//  Copyright (c) 2014 Matt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YTAudioEngine : NSObject


//main initialization functon
-(instancetype)init;

//used to add a lowpass filter to input data
-(void)addLowpassFilterToInputWithCutoff:(float) cutoffFreq;

-(void)beginRecording;

-(void)endRecording;

@end
