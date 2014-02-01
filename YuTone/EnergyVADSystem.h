//
//  EnergyVADSystem.h
//  AEFun
//
//  Created by Matt on 1/27/14.
//  Copyright (c) 2014 Matt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EnergyVADSystem : NSObject

-(void)determineVAD;
-(instancetype)initWithProcessingBlockSize:(NSUInteger) size;
-(float)detectEnergy:(float *) array
     andAppendToList:(BOOL) yesOrNo;

@property (strong, nonatomic) NSMutableArray * packetEnergies;


@property (strong, nonatomic) NSArray * VADdecisions;
@end
