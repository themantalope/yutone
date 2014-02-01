//
//  PitchDetector.h
//  AEFun
//
//  Created by Matt on 1/27/14.
//  Copyright (c) 2014 Matt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PitchDetector : NSObject

//main init function

-(instancetype)initAndAllocate:(NSUInteger) processingBlockSize;

-(float)calculatePitchNCCF:(float *) inputData
              withSampling:(int) samplingRate
           withMinLagInSec:(float) minLag
           withMaxLagInSec:(float) maxLag
      appendFreqencyToList:(BOOL) appendToFreqList;

@property (strong, nonatomic) NSMutableArray * detectedPitches;


@end
