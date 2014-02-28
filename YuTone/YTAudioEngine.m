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
const int kAnalysisBlockSize = kBlockSizeForProcessing/2;
const int kAnalysisOverlap = 64;
const float kMinLag = 1.25/1000.0;
const float kMaxLag = 25.0/1000.0;
const float timerFireInterval = 512.0/44100.0;
const float samplingRate = 44100.0f;

static TPCircularBuffer sharedBuffer;


@interface YTAudioEngine(){
    BOOL _bufferHasBeenInit;
    float * _analysisBufferPreFilter;
    float * _analysisBufferPostFilter;
    int _numSamplesAnalyzed;
    
}

@property (strong, nonatomic) AEAudioController * controller;
@property (strong, nonatomic) AEAudioUnitFilter * lowpassFilter;
@property (strong, nonatomic) AudioRecieverCircWriter * reciever;
@property (strong, nonatomic) WienerFilter * wienerFilter;
@property (strong, nonatomic) PitchDetector * pitchDetector;
@property (strong, nonatomic) EnergyVADSystem * energyDetector;
@property (strong, nonatomic) NSTimer * analysisTimer;


@property (strong, nonatomic) NSMutableArray * debuggingArray;

@end

@implementation YTAudioEngine

-(NSMutableArray *)debuggingArray
{
    if (!_debuggingArray) {
        _debuggingArray = [[NSMutableArray alloc] init];
    }
    
    return _debuggingArray;
}

//first implement the lazy instantiation
//of instance variables

-(NSArray *)detectedPitches
{
    if (!_detectedPitches) {
        _detectedPitches = [[NSArray alloc] initWithObjects:[NSNumber numberWithFloat:0.0f], nil];
    }
    
    return _detectedPitches;
}

-(NSArray *)detectedPitchesTimes
{
    if (!_detectedPitchesTimes) {
        _detectedPitchesTimes = [[NSArray alloc] initWithObjects:[NSNumber numberWithFloat:0.0f], nil];    }
    
    return _detectedPitchesTimes;
}

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

-(void)resetDataArrays
{
    self.detectedPitches = nil;
    self.detectedPitchesTimes = nil;
}

-(void)resetPitchDetectorData
{
    [self.pitchDetector.detectedPitches removeAllObjects];
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
    [self determineDetectedPitchesAndTimes];
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
        
        [self.pitchDetector calculatePitchNCCF:self->_analysisBufferPreFilter withMinLagInSec:kMinLag withMaxLagInSec:kMaxLag];
        
        [self.energyDetector detectEnergy:self->_analysisBufferPostFilter andAppendToList:YES];
        
        
        for (int i = 0; i < kBlockSizeForProcessing; i++) {
            [self.debuggingArray addObject:[NSNumber numberWithFloat:self->_analysisBufferPostFilter[i]]];
        }
        
        //now that we are done consume the buffer
        
        TPCircularBufferConsume(&sharedBuffer, kBlockSizeForProcessing * sizeof(float));
        
        
        //reset our buffers
        vDSP_vclr(self->_analysisBufferPostFilter, 1, kBlockSizeForProcessing);
        vDSP_vclr(self->_analysisBufferPreFilter, 1, kBlockSizeForProcessing);
        self->_numSamplesAnalyzed += kBlockSizeForProcessing;
    }
    
    
    
}

-(void)determineDetectedPitchesAndTimes
{
    
    [self resetDataArrays];
    //first calculate the total time of recorded data
    
    float analyzedTime = ((float) self->_numSamplesAnalyzed)/(samplingRate);
    
    NSNumber * nAnalysisPoints =[NSNumber numberWithInt:[self.pitchDetector.detectedPitches count]];
    
    float timeSpacing = (analyzedTime)/([nAnalysisPoints floatValue]);
    float start = 0.0f;
    //create an NSMutableArray with the times in there
    
    NSMutableArray * times = [[NSMutableArray alloc] initWithCapacity:[nAnalysisPoints integerValue]];
    
    for (int i = 0 ; i < [nAnalysisPoints intValue]; i++) {
        [times addObject:[NSNumber numberWithFloat:(start + timeSpacing)]];
        start += timeSpacing;
    }
    
    //next figure out what points pass the treshold,
    //get that from the energy detector
    
    [self.energyDetector determineVAD];
    
    NSMutableArray * pitches = [self.pitchDetector.detectedPitches mutableCopy];
    
    for (int i = 0; i < [pitches count]; i++) {
        if (![self.energyDetector.VADdecisions objectAtIndex:i]) {
            //if it didn't pass the vad test
            [pitches removeObjectAtIndex:i];
            [times removeObjectAtIndex:i];
        }
    }
    
    //set our properties
    
    self.detectedPitches = [pitches copy];
    self.detectedPitchesTimes = [times copy];

    [self resetPitchDetectorData];
    
    
    
}

#pragma mark - debugging functions

-(void)printArray:(NSArray *)array withPre:(NSString*) prefix
{
    for (int i = 0; i < [array count]; i++) {
        float cur = [(NSNumber *) [array objectAtIndex:i] floatValue];
        printf("%s [%d]: %f\n", [prefix UTF8String],i, cur);
    }
}


-(void)writeArray:(NSArray *)array toFile:(NSString *)filename
{
    //get a path
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@",documentsDirectory,filename];
    
    [array writeToFile:filePath atomically:YES];
    NSLog(@"%@", filePath);
}



@end


