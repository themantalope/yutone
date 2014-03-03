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

-(instancetype)initAndAllocate:(NSUInteger) processingBlockSize
              withFrameOverlap:(NSUInteger) overlap
          withTotalBlockLength:(NSUInteger) totalLengthofBlock
          withDataSamplingRate:(NSNumber *) samplingRate;


-(void)calculatePitchNCCF:(float *) inputData
          withMinLagInSec:(float) minLag
          withMaxLagInSec:(float) maxLag;


@property (strong, nonatomic) NSMutableArray * detectedPitches;
@property (strong, nonatomic) NSMutableArray * detectedCorrCoeffs;

@end
