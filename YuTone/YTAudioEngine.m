//
//  YTAudioEngine.m
//  YuTone
//
//  Created by Matt on 2/1/14.
//  Copyright (c) 2014 Matt. All rights reserved.
//

#import "YTAudioEngine.h"
#import "TPCircularBuffer.h"
#import <Accelerate/Accelerate.h>
#import "TheAmazingAudioEngine.h"
#import "AudioRecieverCircWriter.h"

#import "WienerFilter.h"


const int kBlockSizeForProcessing = 1024;
const int kAnalysisBlockSize = 512;
const int kAnalysisOverlap = 256;
const float kMinLag = 1.25/1000.0;
const float kMaxLag = 25.0/1000.0;
const float timerFireInterval = 512.0/44100.0;

static TPCircularBuffer sharedBuffer;


@interface YTAudioEngine(){
    BOOL _bufferHasBeenInit;
    float * _analysisBufferPreFilter;
    float * _analysisBufferPostFilter;
    
}

@property (strong, nonatomic) AEAudioController * controller;
@property (strong, nonatomic) AEAudioUnitFilter * lowpassFilter;
@property (strong, nonatomic) AudioRecieverCircWriter * reciever;
@property (strong, nonatomic) WienerFilter * wienerFilter;

@property (strong, nonatomic) NSTimer * analysisTimer;

@end

@implementation YTAudioEngine


//first implement the lazy instantiation
//of instance variables

-(AEAudioController *)controller
{
    if (!_controller) {
        _controller = [[AEAudioController alloc] initWithAudioDescription:[AEAudioController audioUnitCanonicalAudioDescription] inputEnabled:YES];
    }
    
    return _controller;
}

-(AEAudioUnitFilter *)lowpassFilter
{
    if (!_lowpassFilter) {
        
        NSError * error = NULL;
        
        
        AudioComponentDescription desc = AEAudioComponentDescriptionMake(kAudioUnitManufacturer_Apple, kAudioUnitType_Effect, kAudioUnitSubType_LowPassFilter);
        
        _lowpassFilter = [[AEAudioUnitFilter alloc] initWithComponentDescription:desc audioController:self.controller error:&error];
    }
    
    return _lowpassFilter;
}

-(AudioRecieverCircWriter *)reciever
{
    if (!_reciever) {
        
        
        if (!self->_bufferHasBeenInit) {
            TPCircularBufferInit(&sharedBuffer, kBlockSizeForProcessing * sizeof(float));
            self->_bufferHasBeenInit = YES;
        }
        
        _reciever = [[AudioRecieverCircWriter alloc] initWithController:self.controller andCircularBuffer:&sharedBuffer];
    }
    
    return _reciever;
}

-(void)allocateResources
{
    self->_bufferHasBeenInit = NO;
    self->_analysisBufferPreFilter = (float *) calloc(kBlockSizeForProcessing, sizeof(float));
    self->_analysisBufferPostFilter = (float *) calloc(kBlockSizeForProcessing, sizeof(float));
}

-(void)cleanUpResources
{
    free(self->_analysisBufferPreFilter);
    free(self->_analysisBufferPostFilter);
    TPCircularBufferCleanup(&sharedBuffer);
}

-(PitchDetector *)pitchDetector
{
    if (!_pitchDetector) {
        _pitchDetector = [[PitchDetector alloc] initAndAllocate:kAnalysisBlockSize withFrameOverlap:kAnalysisOverlap withTotalBlockLength:kBlockSizeForProcessing withDataSamplingRate:[NSNumber numberWithFloat:(float)self.controller.audioDescription.mSampleRate]];
    }
    
    return _pitchDetector;
}


-(WienerFilter *)wienerFilter
{
    if (!_wienerFilter) {
        _wienerFilter = [[WienerFilter alloc] initAndAllocate:kBlockSizeForProcessing];
    }
    
    return _wienerFilter;
}

-(EnergyVADSystem *)energyDetector
{
    if (!_energyDetector) {
        _energyDetector = [[EnergyVADSystem alloc]initWithProcessingBlockSize:kAnalysisBlockSize andFrameOverlap:kAnalysisOverlap withTotalBlockSize:kBlockSizeForProcessing];
    }
    
    return _energyDetector;
}

-(NSTimer *)analysisTimer
{
    if (!_analysisTimer) {
        _analysisTimer = [[NSTimer alloc] init];
    }
    
    return _analysisTimer;
}

-(instancetype)init
{
    self = [super init];
    if (self) {
        //connect the input
        [self.controller addInputReceiver:self.reciever];
        //allocate resources for stuff we def need
        [self allocateResources];
        
        self.pitchDetector = [self pitchDetector];
        self.analysisTimer = [self analysisTimer];
        self.energyDetector = [self energyDetector];
        self.wienerFilter = [self wienerFilter];
        
        
    }
    
    return self;
}

-(void)dealloc
{
    [self cleanUpResources];
}

-(void)addLowpassFilterToInputWithCutoff:(float)cutoffFreq
{
    AudioUnitSetParameter(self.lowpassFilter.audioUnit,
                          kLowPassParam_CutoffFrequency,
                          kAudioUnitScope_Global,
                          0,
                          cutoffFreq,
                          0);
    [self.controller addInputFilter:self.lowpassFilter];
}


-(void)beginRecording
{
    self.analysisTimer = [NSTimer timerWithTimeInterval:timerFireInterval target:self selector:@selector(filterAndMeasureParameters:) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.analysisTimer forMode:NSRunLoopCommonModes];
    
    NSError * err = nil;
    
    [self.controller start:&err];
}

-(void)endRecording
{
    [self.controller stop];
    
    [self.analysisTimer invalidate];
    self.analysisTimer = nil;
}

-(void)filterAndMeasureParameters:(NSTimer *) timer
{
    //first get the data and filter it
    
    int availBytes = 0;
    
    self->_analysisBufferPreFilter = TPCircularBufferTail(&sharedBuffer, &availBytes);
    
    int availFrames = availBytes/sizeof(float);
    
    if (availFrames >= kBlockSizeForProcessing) {
        //do the processing
        
        //filter
        [self.wienerFilter filterData:self->_analysisBufferPreFilter withOutput:_analysisBufferPostFilter];
        
        //analyze
        
        [self.pitchDetector calculatePitchNCCF:self->_analysisBufferPostFilter withMinLagInSec:kMinLag withMaxLagInSec:kMaxLag];
        
        [self.energyDetector detectEnergy:self->_analysisBufferPostFilter andAppendToList:YES];
        
        //now that we are done consume the buffer
        
        TPCircularBufferConsume(&sharedBuffer, kBlockSizeForProcessing * sizeof(float));
        
        
        //reset our buffers
        vDSP_vclr(self->_analysisBufferPostFilter, 1, kBlockSizeForProcessing);
        vDSP_vclr(self->_analysisBufferPreFilter, 1, kBlockSizeForProcessing);
        
    }
    
    
    
}



@end
