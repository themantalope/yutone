//
//  AudioRecieverCircWriter.m
//  AEFun
//
//  Created by Matt on 2/1/14.
//  Copyright (c) 2014 Matt. All rights reserved.
//

#import "AudioRecieverCircWriter.h"
#import "AEFloatConverter.h"

@interface AudioRecieverCircWriter(){
    TPCircularBuffer * _circBuff;
}
@property (strong, nonatomic) AEFloatConverter * converter;


@end



@implementation AudioRecieverCircWriter

-(instancetype)initWithController:(AEAudioController *)controller andCircularBuffer:(TPCircularBuffer *)sharedBuffer
{
    self = [super init];
    if (self) {
        self.converter = [[AEFloatConverter alloc] initWithSourceFormat:controller.audioDescription];
        
        self->_circBuff = sharedBuffer;
    }
    
    return self;
}

-(AEFloatConverter *)converter
{
    if (!_converter) {
        _converter = [[AEFloatConverter alloc] init];
    }
    return _converter;
}



static void receiverCallback(id receiver,
                             AEAudioController * audioController,
                             void * source,
                             const AudioTimeStamp * time,
                             UInt32 frames,
                             AudioBufferList * audio)
{
    
    AudioRecieverCircWriter *THIS = (AudioRecieverCircWriter *)receiver;
    
    // Do something with 'audio'
    
    //write audio to circular buffer
    
    AudioBufferList * tempBuff = audio;
    
    BOOL success = AEFloatConverterToFloatBufferList(THIS->_converter, audio, tempBuff, frames);
    
    if (success) {
        TPCircularBufferProduceBytes((THIS->_circBuff), tempBuff->mBuffers[0].mData, frames);
    }

}


-(AEAudioControllerAudioCallback)receiverCallback
{
    return receiverCallback;
}

@end
