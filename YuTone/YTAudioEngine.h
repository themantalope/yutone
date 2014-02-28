//
//  YTAudioEngine.h
//  YuTone
//
//  Created by Matt on 2/1/14.
//  Copyright (c) 2014 Matt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PitchDetector.h"
#import "EnergyVADSystem.h"

@interface YTAudioEngine : NSObject


@property (strong, nonatomic) NSArray * detectedPitches;
@property (strong, nonatomic) NSArray * detectedPitchesTimes;


//main initialization functon
-(instancetype)init;

//used to add a lowpass filter to input data
-(void)addLowpassFilterToInputWithCutoff:(float) cutoffFreq;

-(void)beginRecording;

-(void)endRecording;

@end
