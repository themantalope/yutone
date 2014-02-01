//
//  AudioRecieverCircWriter.h
//  AEFun
//
//  Created by Matt on 2/1/14.
//  Copyright (c) 2014 Matt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TheAmazingAudioEngine.h"
#import "TPCircularBuffer.h"

@interface AudioRecieverCircWriter : NSObject <AEAudioReceiver>

-(instancetype)initWithController:(AEAudioController *) controller
                andCircularBuffer:(TPCircularBuffer *) sharedBuffer;

@end
