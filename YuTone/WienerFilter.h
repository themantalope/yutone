//
//  WienerFilter.h
//  AEFun
//
//  Created by Matt on 1/26/14.
//  Copyright (c) 2014 Matt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WienerFilter : NSObject



//public methods

//preferred initializer
//@param : processingBlockSize - integer, should be
//equal to length of input data array
-(instancetype)initAndAllocate:(NSUInteger) processingBlockSize;


//main function used to do processing of data
//@param:inputData - the input array
//@para:output - an array to store the result
-(void)filterData:(float *) inputData withOutput:(float *) output;



//method to safely deallocate malloc'd arrays
-(void)cleanUpResources;


@end
