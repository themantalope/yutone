//
//  WienerFilter.m
//  AEFun
//
//  Created by Matt on 1/26/14.
//  Copyright (c) 2014 Matt. All rights reserved.
//

#import "WienerFilter.h"
#import "ind2sub.h"
#import <Accelerate/Accelerate.h>




@interface WienerFilter(){
    float * _Rxx;//signal autocorrelation matrix
    float * _rxy;//'ideal' signal
    float * _w;//the filter coeffs
    float * _err;//the error vector
    float _mu;//the gradient descent step
    float _currentError;//the current cost
    float _lastError;//the last cost
    UInt32 _n;//number of frames, hence rows, cols
    float _oneOverN;//1/n
    float _alpha;//used for convergence checking
    float _traceRxx;//the trace of matrix Rxx, used for mu calculation
}

@end




@implementation WienerFilter

-(void)allocateResources:(NSUInteger) processingBlockSize
{
    self->_n = (int) processingBlockSize;
    self->_mu = 0;
    self->_alpha = 0;
    self->_currentError = 0;
    self->_oneOverN = 1/((float) self->_n);
    self->_lastError = 0;
    self->_traceRxx = 0;
    self->_w = (float *) malloc(self->_n * sizeof(float));
    self->_err = (float *) malloc(self->_n * sizeof(float));
    self->_rxy = (float *) malloc(self->_n * sizeof(float));
    self->_Rxx = (float *) malloc(self->_n * self->_n * sizeof(float));
}

-(void)cleanUpResources
{
    free(self->_w);
    free(self->_err);
    free(self->_Rxx);
    free(self->_rxy);
}

-(void)dealloc
{
    [self cleanUpResources];
}

-(instancetype)initAndAllocate:(NSUInteger)processingBlockSize
{
    self = [super init];
    
    if (self) {
        [self allocateResources:processingBlockSize];
    }
    
    return self;
    
}

-(void)filterData:(float *)inputData withOutput:(float *) output
{
    filterDataCfunction(self, inputData, output);
}

void filterDataCfunction(id wienerFilterObj, float * inputData, float * output)
{
    WienerFilter * THIS = (WienerFilter *) wienerFilterObj;
    
    //first get the mean of the input
    float xmean = 0;
    //get the mean of x
    vDSP_meanv(inputData, 1, &xmean, THIS->_n);

    //subtract it from input
    xmean *= -1.0;
    
    vDSP_vsadd(inputData, 1, &xmean, inputData, 1,
               THIS->_n);
    
    
    //next compute Rxx
    
    cblas_sgemm(CblasColMajor,
                CblasNoTrans,
                CblasNoTrans,
                THIS->_n,
                THIS->_n,
                1,
                (float) 1.0,
                inputData,
                THIS->_n,
                inputData,
                1,
                THIS->_oneOverN,
                THIS->_Rxx,
                THIS->_n);
    
    //next compute rxy
    
    cblas_sgemm(CblasColMajor,
                CblasTrans,
                CblasNoTrans,
                THIS->_n,
                1,
                THIS->_n,
                (float) 1.0,
                THIS->_Rxx,
                THIS->_n,
                inputData,
                THIS->_n,
                (float) 1.0,
                THIS->_rxy,
                THIS->_n);
    
    //get the trace of Rxx
    
    float traceRxx = calculateTrace(THIS->_Rxx, THIS->_n);
    
    //calculate mu
    
    THIS->_mu = 1/traceRxx;
    THIS->_mu *= (float) 2.0;//for the gradient descent step
    
    
    //set the w vector to zero
    vDSP_vclr(THIS->_w, 1, THIS->_n);
    
    //enter the loop
    int iters = 0;
    
    while (true) {
        //first calculate the output
        cblas_sgemm(CblasColMajor,
                    CblasNoTrans,
                    CblasNoTrans,
                    THIS->_n,
                    1,
                    THIS->_n,
                    (float) 1.0,
                    THIS->_Rxx,
                    THIS->_n,
                    THIS->_w,
                    THIS->_n,
                    (float) 1.0,
                    output,
                    THIS->_n);
        
        //next find the error
        
        vDSP_vsub(output,
                  1,
                  THIS->_rxy,
                  1,
                  THIS->_err,
                  1,
                  THIS->_n);
        //calculate the cost
        
        THIS->_lastError = THIS->_currentError;
        THIS->_currentError = squareErrorCostFunction(THIS->_err, THIS->_n);
        
        THIS->_alpha = 0.05 * THIS->_lastError;
        //evaluate for convergence
        if ((THIS->_currentError < THIS->_lastError + THIS->_alpha) &&
            (THIS->_currentError > THIS->_lastError - THIS->_alpha)) {
            break;
        }
        else if (iters > 150){
            break;
        }
        else{
            //update w
            catlas_saxpby(THIS->_n,
                          THIS->_mu,
                          THIS->_err,
                          1,
                          (float) 1.0,
                          THIS->_w,
                          1);
            iters++;
        }
    }
    
    //now the result is stored in output
    vDSP_vclr(THIS->_w, 1, THIS->_n);
    vDSP_vclr(THIS->_err, 1, THIS->_n);
    vDSP_vclr(THIS->_rxy, 1, THIS->_n);
    vDSP_vclr(THIS->_Rxx, 1, THIS->_n * THIS->_n);
    
}



float calculateTrace(float * matrix, UInt32 length)
{
    //computes trace for a lengthxlength matrix
    float trace = 0;
    UInt32 N = 2;//number of dimensions
    int * matrixSize = (int *) malloc(2 * sizeof(int));//matrix size
    matrixSize[0] = length;
    matrixSize[1] = length;
    
    int * curSubscript = (int *) malloc(2 * sizeof(int));
    
    for (int i = 0; i < length; i++) {
        curSubscript[0] = i;
        curSubscript[1] = i;
        int idx = sub2ind(matrixSize, N, curSubscript);
        trace += matrix[idx];
    }
    
    free(matrixSize);
    free(curSubscript);
    
    return trace;
}

float squareErrorCostFunction(float * array, int N)
{
    float cost = 0;
    
    //get the sum of the squares
    vDSP_svesq(array, 1, &cost, N);
    
    cost *= (1/ (2*(float)N));
    
    return cost;
}


@end
