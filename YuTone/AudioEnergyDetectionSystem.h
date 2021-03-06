//
//  EnergyVADSystem.h
//  AEFun
//
//  Created by Matt on 1/27/14.
//  Copyright (c) 2014 Matt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AudioEnergyDetectionSystem : NSObject

-(void)determineVAD;
-(instancetype)initWithProcessingBlockSize:(NSUInteger)size
                           andFrameOverlap:(NSUInteger) overlap
                        withTotalBlockSize:(NSUInteger) totalBlockSize;


-(void)detectEnergy:(float *) array
     andAppendToList:(BOOL) yesOrNo;

@property (strong, nonatomic) NSMutableArray * packetEnergies;


@property (strong, nonatomic) NSArray * VADdecisions;
@end
