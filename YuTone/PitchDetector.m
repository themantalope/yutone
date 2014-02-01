//
//  PitchDetector.m
//  AEFun
//
//  Created by Matt on 1/27/14.
//  Copyright (c) 2014 Matt. All rights reserved.
//

#import "PitchDetector.h"
#import <Accelerate/Accelerate.h>
#import <math.h>


@interface PitchDetector(){
    DSPSplitComplex _dataFFT;
    DSPSplitComplex _dataFFTconj;
    float * _hanningWindowForInput;
    float * _NCCFdata;
    FFTSetup _fftsetup;
    int _inputDataLength;
    int _fftLength;
    int _fftLengthOver2;
    int _fftLog2N;
    int _samplingRate;
}




@end





@implementation PitchDetector

//lazy instantiation

-(NSMutableArray *)detectedPitches
{
    if (!_detectedPitches) {
        _detectedPitches = [[NSMutableArray alloc] init];
    }
    
    return _detectedPitches;
}

-(instancetype)initAndAllocate:(NSUInteger)processingBlockSize
{
    self = [super init];
    if (self) {
        [self allocateResourcesWithDataLength:processingBlockSize];
        self.detectedPitches = [[NSMutableArray alloc] init];
    }
    
    return self;
}


-(void)allocateResourcesWithDataLength:(NSUInteger) processingBlockSize
{
    int dataLength = (int) processingBlockSize;
    self->_inputDataLength = dataLength;
    dataLength *= 2;
    dataLength++;
    self->_fftLog2N = (int) floor(log2f((float) dataLength - 1));
    self->_fftLog2N += 1;//this is the next power of 2 larger than the length of the input data
    self->_fftLength = 1 << self->_fftLog2N;
    self->_fftLengthOver2 = self->_fftLength / 2;
    self->_fftsetup = vDSP_create_fftsetup(self->_fftLog2N, kFFTRadix2);
    self->_dataFFT.realp = (float *) calloc(self->_fftLengthOver2, sizeof(float));
    self->_dataFFT.imagp = (float *) calloc(self->_fftLengthOver2, sizeof(float));
    self->_dataFFTconj.realp = (float *) calloc(self->_fftLengthOver2, sizeof(float));
    self->_dataFFTconj.imagp = (float *) calloc(self->_fftLengthOver2, sizeof(float));
    //now both the fft and the conj vectors have been
    //initialized with all values set to zero
    self->_hanningWindowForInput = (float *) calloc(self->_inputDataLength, sizeof(float));
    vDSP_hann_window((self->_hanningWindowForInput),
                     self->_inputDataLength,
                     vDSP_HANN_NORM);
    self->_NCCFdata = calloc(self->_fftLength,
                             sizeof(float));
}

-(void)cleanUpResources
{
    free(self->_dataFFT.realp);
    free(self->_dataFFT.imagp);
    free(self->_dataFFTconj.realp);
    free(self->_dataFFTconj.imagp);
    free(self->_NCCFdata);
    vDSP_destroy_fftsetup(self->_fftsetup);
    free(self->_hanningWindowForInput);
}

-(void)dealloc
{
    [self cleanUpResources];
}

-(float)calculatePitchNCCF:(float *) inputData
              withSampling:(int) samplingRate
           withMinLagInSec:(float) minLag
           withMaxLagInSec:(float) maxLag
      appendFreqencyToList:(BOOL) appendToFreqList
{
    float f0 = calculatePitchNCCF(self,
                                  inputData,
                                  samplingRate,
                                  minLag,
                                  maxLag);
    
    if (appendToFreqList) {
        [self.detectedPitches addObject:[NSNumber numberWithFloat:f0]];
    }
    
    return f0;
}


float calculatePitchNCCF(id pitchDetectorObj,
                         float * inputData,
                         int samplingRate,
                         float minLag,
                         float maxLag)
{
    
    PitchDetector * THIS = (PitchDetector *) pitchDetectorObj;
    
    
    float f0 = 0;
    
    //first calculate the norm of the input array for the scaling later
    float arrayNorm = cblas_snrm2(THIS->_inputDataLength,
                                  inputData,
                                  1);
    float scalingFactor = powf(arrayNorm, (float) 2.0);
    
    
    
    
    scalingFactor = 1/scalingFactor;
       
    //also get some helper parameters
    
    int minIdx = (int) floorf(minLag * ((float) samplingRate));
    int maxIdx = (int) floorf(maxLag * ((float) samplingRate));
    
    //now we need to multiply the input by the hanning window
    
    vDSP_vmul(inputData,
              1,
              (THIS->_hanningWindowForInput),
              1,
              inputData,
              1,
              THIS->_inputDataLength);
    
    
    //now we can get the data into our fft stuff
    
    vDSP_ctoz((DSPComplex *) inputData,
              2,
              &(THIS->_dataFFT),
              1,
              THIS->_inputDataLength/2);
    
    //let it rip! (harupmh) the forward FFT that is...
    
    vDSP_fft_zrip(THIS->_fftsetup,
                  &(THIS->_dataFFT),
                  1,
                  THIS->_fftLog2N,
                  kFFTDirection_Forward);
    
    //kk, now we have the forward FFT data, copy that into
    //the other complex buffer and then conjugate
    
    vDSP_zvmov(&THIS->_dataFFT,
               1,
               &THIS->_dataFFTconj,
               1,
               THIS->_fftLengthOver2);
    
    //found a nice little function that does the conjugation and
    //multiplication in one step
    
    vDSP_zvcmul(&(THIS->_dataFFTconj),
                1,
                &(THIS->_dataFFT),
                1,
                &(THIS->_dataFFT),
                1,
                THIS->_fftLengthOver2);
    
    
    
    
    //so now the multiplied complex conjugate is in the
    //_dataFFT vector, take the IFFT
    
    vDSP_fft_zrip(THIS->_fftsetup,
                  &(THIS->_dataFFT),
                  1,
                  THIS->_fftLog2N,
                  kFFTDirection_Inverse);
    
    //get the data into a new vector for processing
    
    vDSP_ztoc(&(THIS->_dataFFT),
              1,
              (COMPLEX *)THIS->_NCCFdata,
              2,
              THIS->_fftLengthOver2);
    

    
    
    //normalize it
    
    vDSP_vsmul(THIS->_NCCFdata,
               1,
               &scalingFactor,
               THIS->_NCCFdata,
               1,
               THIS->_fftLengthOver2);
    
    //now check the new vector for its peak
    
    int argmax = 0;
    float curmax = 0;
    
    for (int i = minIdx; i < maxIdx ; i++) {
        if (THIS->_NCCFdata[i] > curmax) {
            curmax = THIS->_NCCFdata[i];
            argmax = i;
        }
    }
    
    float f0Per = ((float) argmax)/((float) samplingRate);
    
    f0 = 1/f0Per;
    
    
    
    //clear out the vectors
    
    vDSP_vclr(THIS->_dataFFT.realp, 1, THIS->_fftLengthOver2);
    vDSP_vclr(THIS->_dataFFT.imagp, 1, THIS->_fftLengthOver2);
    
    vDSP_vclr(THIS->_dataFFTconj.realp, 1, THIS->_fftLengthOver2);
    vDSP_vclr(THIS->_dataFFTconj.imagp, 1, THIS->_fftLengthOver2);
    
    vDSP_vclr(THIS->_NCCFdata, 1, THIS->_fftLength);
    
    
    
    return f0;
}





@end
