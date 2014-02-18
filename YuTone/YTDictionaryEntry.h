//
//  YTDictionaryEntry.h
//  AEFun
//
//  Created by Matt on 2/17/14.
//  Copyright (c) 2014 Matt. All rights reserved.
//

#import <Foundation/Foundation.h>

enum ytdeKeyValues {
    ytdeTraditional = 0,
    ytdeSimplified = 1,
    ytdePinyinWithNumbers = 2,
    ytdePinyinWithMarks = 3,
    ytdeDefinitions = 4
    };



@interface YTDictionaryEntry : NSObject


@property (strong, nonatomic) NSDictionary * fullEntry;
@property (weak, nonatomic) NSString * traditional;
@property (weak, nonatomic) NSString * simplified;
@property (weak, nonatomic) NSString * pinyinWithNumbers;
@property (weak, nonatomic) NSString * pinyinWithMarks;
@property (weak, nonatomic) NSString * definitions;


//main ini method, needs an array whose index
//values and objects at index need to match the
//ytdKeyValues

-(instancetype)initWithEntryArray:(NSArray *) inputEntryArray;

@end
