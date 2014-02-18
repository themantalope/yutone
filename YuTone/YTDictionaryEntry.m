//
//  YTDictionaryEntry.m
//  AEFun
//
//  Created by Matt on 2/17/14.
//  Copyright (c) 2014 Matt. All rights reserved.
//

#import "YTDictionaryEntry.h"



@implementation YTDictionaryEntry

+(NSArray *)getKeyValuesAsArray
{
    NSMutableArray * kvArray = [[NSMutableArray alloc] initWithCapacity:5];
    
    for (int i = 0; i < 5; i++) {
        [kvArray addObject:[NSNumber numberWithInt:i]];
    }
    
    
    
    return [kvArray copy];
}

-(instancetype)initWithEntryArray:(NSArray *)inputEntryArray
{
    self = [super init];
    
    if (self) {
        //do the initializations
        
        if ([inputEntryArray count] == [[YTDictionaryEntry getKeyValuesAsArray] count]) {
            self.fullEntry = [NSDictionary dictionaryWithObjects:inputEntryArray forKeys:[YTDictionaryEntry getKeyValuesAsArray]];
        }
        
    }
    
    return self;
}


-(NSDictionary *)fullEntry
{
    if (!_fullEntry) {
        _fullEntry = [[NSDictionary alloc] init];
    }
    
    return _fullEntry;
}

-(NSString *)traditional
{
    if (!_traditional) {
        _traditional = [self.fullEntry objectForKey:[NSNumber numberWithInt:ytdeTraditional]];
    }
    
    return _traditional;
}

-(NSString *)simplified
{
    if (!_simplified) {
        _simplified = [self.fullEntry objectForKey:[NSNumber numberWithInt:ytdeSimplified]];
    }
    
    return _simplified;
}

-(NSString *)pinyinWithNumbers
{
    if (!_pinyinWithNumbers) {
        _pinyinWithNumbers = [self.fullEntry objectForKey:[NSNumber numberWithInt:ytdePinyinWithNumbers]];
    }
    
    return _pinyinWithNumbers;
}

-(NSString *)pinyinWithMarks
{
    if (!_pinyinWithMarks) {
        _pinyinWithMarks = [self.fullEntry objectForKey:[NSNumber numberWithInt:ytdePinyinWithMarks]];
    }
    
    return _pinyinWithMarks;
}

-(NSString *)definitions
{
    if (!_definitions) {
        _definitions = [self.fullEntry objectForKey:[NSNumber numberWithInt:ytdeDefinitions]];
    }
    
    return _definitions;
}



@end
