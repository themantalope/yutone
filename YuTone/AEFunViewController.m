//
//  AEFunViewController.m
//  AEFun
//
//  Created by Matt on 1/14/14.
//  Copyright (c) 2014 Matt. All rights reserved.
//

#import "AEFunViewController.h"
#import "TheAmazingAudioEngine.h"
#import "AEFloatConverter.h"
#import "LowPassRecorder.h"


@interface AEFunViewController ()

@property (nonatomic, strong) AEAudioController * audioController;
@property (nonatomic, strong) NSMutableArray * recordedData;
@property (nonatomic, strong) AEFloatConverter * converter;
@property (nonatomic, strong) LowPassRecorder * recorder;

@end

@implementation AEFunViewController

- (AEAudioController *)audioController
{
    if(!_audioController){
        _audioController = [[AEAudioController alloc] initWithAudioDescription:[AEAudioController audioUnitCanonicalAudioDescription] inputEnabled:YES];
    }
    
    return _audioController;
}

- (NSMutableArray *)recordedData
{
    if (!_recordedData) {
        _recordedData = [[NSMutableArray alloc] init];
    }
    
    return _recordedData;
}

- (AEFloatConverter *)converter
{
    if(!_converter){
        _converter = [[AEFloatConverter alloc] initWithSourceFormat:[AEAudioController audioUnitCanonicalAudioDescription]];
    }
    
    return _converter;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.audioController = [[AEAudioController alloc]
                            initWithAudioDescription:[AEAudioController audioUnitCanonicalAudioDescription] inputEnabled:YES];
    
    self.converter = [[AEFloatConverter alloc] initWithSourceFormat:[AEAudioController audioUnitCanonicalAudioDescription]];
    
    //setup the input receiver
    
    __weak AEFunViewController * wself = self;
    
    id<AEAudioReceiver> receiver = [AEBlockAudioReceiver audioReceiverWithBlock:
                                    ^(void                     *source,
                                      const AudioTimeStamp     *time,
                                      UInt32                    frames,
                                      AudioBufferList          *audio) {
                                        
                                        
                                        
                                        AudioBufferList * tempBuff = audio;
                                        
                                        BOOL success = AEFloatConverterToFloatBufferList(self.converter,
                                                                                         audio,
                                                                                         tempBuff,
                                                                                         frames);
                                        
                                        if (success) {
                                            for (int i = 0; i < frames; i++) {
                                                [wself.recordedData addObject:[NSNumber numberWithFloat:((float *)tempBuff->mBuffers[0].mData)[i]]];
                                            }
                                        }

                                        
                                        
                                    }];
    AudioComponentDescription component = AEAudioComponentDescriptionMake(kAudioUnitManufacturer_Apple,
                                                                          kAudioUnitType_Effect,
                                                                          kAudioUnitSubType_LowPassFilter);
    
    NSError * error = NULL;
    AEAudioUnitFilter * lowPass = [[AEAudioUnitFilter alloc] initWithComponentDescription:component
                                                                        audioController:self.audioController
                                                                                  error:&error];
    if (!lowPass) {
        NSLog(@"error : %@\n", error);
    }
    
    AudioUnitSetParameter(lowPass.audioUnit,
                          kLowPassParam_CutoffFrequency,
                          kAudioUnitScope_Global,
                          0,
                          800.00,
                          0);
    
    [self.audioController addInputReceiver:receiver];
    //[self.audioController addInputFilter:lowPass];
    
    NSError *err = NULL;
    
    [self.audioController start:&err];
    
    usleep(1000.0 * 1000.0 * 1.0);
    
    [self.audioController stop];
    
    dispatch_queue_t queue = dispatch_queue_create("printingQueue", NULL);
    
    __block BOOL finished = NO;
    
    dispatch_async(queue, ^{
        int count = [self.recordedData count];
        float * floatArray = malloc(sizeof(float) * count);
        for (int i = 0; i < [self.recordedData count]; i++) {
            
            //NSLog(@"recordedData[%d] = %@\n", i, [self.recordedData objectAtIndex:i]);
            
            NSNumber * curNum = [self.recordedData objectAtIndex:i];
            
            floatArray[i] = [curNum floatValue];
            
            
        }
        
        
//        for (int i = 0; i < count; i++) {
//            printf("floatArray[%d] = %f\n", i,floatArray[i]);
//        }
        
        
        
//        NSArray *paths = NSSearchPathForDirectoriesInDomains
//        (NSDocumentDirectory, NSUserDomainMask, YES);
//        NSString *documentsDirectory = [paths objectAtIndex:0];
//        
//        //make a file name to write the data to using the documents directory:
//        NSString *fileName = [NSString stringWithFormat:@"%@/iOSAudioDataUnfiltered.xml",
//                              documentsDirectory];
//        
//        NSLog(@"%@\n", fileName);
//        
//        NSArray * writingArray = [self.recordedData copy];
//        
//        [writingArray writeToFile:fileName
//                  atomically:NO];
        
        
        
        
        free(floatArray);
        
        printf("All done...\n");
        
        finished = YES;
    });
    
    
    while (!finished);
    
    
}
- (IBAction)startRecord:(UIButton *)sender {
    
    self.recorder = [[LowPassRecorder alloc] initWithLowPassFilter:[NSNumber numberWithFloat:800.0]];
    [self.recorder beginRecording];
    
    
}

- (IBAction)stopRecord:(UIButton *)sender {
    
    [self.recorder endRecording];
    
//    for (int i = 0; i < [self.recorder.recordedData count]; i++) {
//        NSLog(@"MyRecorder data [%d] = %@\n",i,self.recorder.recordedData[i]);
//    }
    
    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    //make a file name to write the data to using the documents directory:
    NSString *fileName = [NSString stringWithFormat:@"%@/iOSAudioDataUnfiltered.xml",
                          documentsDirectory];
    
    NSLog(@"%@\n", fileName);
    
    NSArray * writingArray = [self.recorder.recordedData copy];
    
    [writingArray writeToFile:fileName
                   atomically:NO];
    
    NSLog(@"file has been written after button release...\n");
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
