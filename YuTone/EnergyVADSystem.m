//
//  EnergyVADSystem.m
//  AEFun
//
//  Created by Matt on 1/27/14.
//  Copyright (c) 2014 Matt. All rights reserved.
//

#import "EnergyVADSystem.h"
#import <Accelerate/Accelerate.h>


@interface EnergyVADSystem(){
    int _kProcessingBlockSize;
}


@property (strong, nonatomic) NSNumber * SNRThresh;



@end



@implementation EnergyVADSystem

-(NSMutableArray *)packetEnergies
{
    if(!_packetEnergies){
        _packetEnergies = [[NSMutableArray alloc] init];
    }
    
    return _packetEnergies;
}

-(NSNumber *)SNRThresh
{
    if (!_SNRThresh) {
        _SNRThresh = [[NSNumber alloc] initWithFloat:0.0];
    }
    
    return _SNRThresh;
}

-(NSArray *)VADdecisions
{
    if (!_VADdecisions) {
        _VADdecisions = [[NSArray alloc] init];
    }
    
    return _VADdecisions;
}

-(instancetype)initWithProcessingBlockSize:(NSUInteger)size
{
    self = [super init];
    if (self) {
        self->_kProcessingBlockSize = (int) size;
    }
    
    return self;
}

//C implementation, will be wrapped by an obj-C function

float detectEnergy(float * array, int arrayLength)
{
    float energy = 0;
    
    
    
    //first square the array
    vDSP_vsq(array,
             1,
             array,
             1,
             arrayLength);
    
    //now find the sum
    
    vDSP_sve(array,
             1,
             &energy,
             arrayLength);
    
    //return it
    
    
    
    return  energy;
}

-(float)detectEnergy:(float *) array
       andAppendToList:(BOOL) yesOrNo
{
    int arrayLength = self->_kProcessingBlockSize;
    float energy = detectEnergy(array, arrayLength);
    
    if (yesOrNo) {
        [self.packetEnergies addObject:[NSNumber numberWithFloat:energy]];
    }
    
    return energy;
    
}

float getMeanEnergy(float * energiesArray, int arrayLength)
{
    float emean = 0;
    
    vDSP_meanv(energiesArray,
               1,
               &emean,
               arrayLength);
    
    
    return emean;
}

float getEnergyVar(float * energiesArray, int arrayLength)
{
    float evar = 0;
    
    
    float mean = getMeanEnergy(energiesArray, arrayLength);
    
    mean *= (float) -1.0;
    
    //subtract from array
    
    vDSP_vsadd(energiesArray,
               1,
               &mean,
               energiesArray,
               1,
               arrayLength);
    
    //square it
    
    vDSP_vsq(energiesArray,
             1,
             energiesArray,
             1,
             arrayLength);
    
    //get the mean, this is now the variance
    
    vDSP_meanv(energiesArray,
               1,
               &evar,
               arrayLength);
    
    //return it
    
    return evar;
}

float calculateSNRThresh(float * energiesArray, int arrayLength)
{
    float SNRThresh = 0;
    
    float emean = getMeanEnergy(energiesArray, arrayLength);
    float evar = getEnergyVar(energiesArray, arrayLength);
    
    SNRThresh = emean/evar;
    
    return SNRThresh;
}


void decisionVAD(float * energiesArray,
                 bool * output,
                 float SNRThresh,
                 int arrayLength)
{
    
    for (int i = 0; i < arrayLength; i++) {
        if (energiesArray[i] > SNRThresh) {
            output[i] = TRUE;
        }
        else{
            output[i] = FALSE;
        }
    }
    
}

-(void)determineVAD
{
    int energiesArrayLength = [self.packetEnergies count];
    float * earray = calloc(energiesArrayLength, sizeof(float));
    //remeber to free this guy
    NSNumber * curNum = 0;
    for (int i = 0 ; i < energiesArrayLength; i++) {
        curNum = [self.packetEnergies objectAtIndex:i];
        earray[i] = (float) [curNum floatValue];
    }
    
    float SNRT = calculateSNRThresh(earray, energiesArrayLength);
    
    bool * decisions = calloc(energiesArrayLength, sizeof(bool));
    
    decisionVAD(earray, decisions, SNRT, energiesArrayLength);
    
    NSMutableArray * localDec = [[NSMutableArray alloc] init];
    
    for (int i = 0; i<energiesArrayLength; i++) {
        [localDec addObject:[NSNumber numberWithBool:decisions[i]]];
    }
    
    self.VADdecisions = [[NSArray alloc] initWithArray:[localDec copy]];
    
    free(earray);
    free(decisions);
    
}

@end
