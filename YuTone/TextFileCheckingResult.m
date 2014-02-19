//
//  TextFileCheckingResult.m
//  YuTone
//
//  Created by Matt on 2/19/14.
//  Copyright (c) 2014 Matt. All rights reserved.
//

#import "TextFileCheckingResult.h"

@implementation TextFileCheckingResult

//lazy instantiation

-(NSNumber *)lineNumInTextFile
{
    if (!_lineNumInTextFile) {
        _lineNumInTextFile = [[NSNumber alloc] initWithInt:-1];
    }
    
    return _lineNumInTextFile;
}

-(NSURL *)sourceURL
{
    if (!_sourceURL) {
        _sourceURL = [[NSURL alloc] init];
    }
    
    return _sourceURL;
}

-(instancetype)initWithNSTextCheckingResult:(NSTextCheckingResult *)result
{
    self = [super init];
    
    if (self) {
        self.range = result.range;
    }
    
    return self;
}


-(instancetype)initWithLineNum:(NSNumber *)lineNum andRange:(NSRange) range andResourceURL:(NSURL *)URL
{
    self = [super init];
    
    if (self) {
        self.range = range;
        self.lineNumInTextFile = lineNum;
        self.sourceURL = URL;
    }
    
    return self;
}



@end
