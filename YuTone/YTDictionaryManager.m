//
//  YTDictionaryManager.m
//  YuTone
//
//  Created by Matt on 2/19/14.
//  Copyright (c) 2014 Matt. All rights reserved.
//

#import "YTDictionaryManager.h"
#import "YTDictionaryEntry.h"

#define YTDICTIONARY_ENTRYDELIM "\n"
#define YTDICTIONARY_SECTIONDELIM "*"
#define YTDICTIONARY_REGEXOPTIONS NSRegularExpressionCaseInsensitive
#define YTDICTIONARY_ENCODING NSUTF8StringEncoding
//just make sure all dictionaries match these properties

@interface YTDictionaryManager()

@property (strong, nonatomic) NSURL * dictionaryURL;

@end


@implementation YTDictionaryManager

-(NSString *)latestKeyword
{
    if (!_latestKeyword) {
        _latestKeyword = [[NSString alloc] init];
    }
    
    return _latestKeyword;
}

-(NSMutableArray *)latestSearchResults
{
    if (!_latestSearchResults) {
        _latestSearchResults = [[NSMutableArray alloc] init];
    }
    
    return _latestSearchResults;
}


-(NSURL *)dictionaryURL
{
    if (!_dictionaryURL) {
        _dictionaryURL = [[NSURL alloc] init];
    }
    
    return _dictionaryURL;
}

-(instancetype)initWithDictionaryURL:(NSURL *)URL
{
    self = [super init];
    
    if (self) {
        self.dictionaryURL = URL;
    }
    
    return self;
}

-(void)getEntriesForKeyword:(NSString *)keyword
{
    
    printf("searching...");
    
    [self resetSearchResults];
    
    NSArray * searchResultsAsStrings = [self getDictionaryEntriesForKeyword:keyword withEntryDelimiter:[YTDictionaryManager entryDelimiterAsNSString] forURL:self.dictionaryURL withEncoding:YTDICTIONARY_ENCODING withRegExOptions:YTDICTIONARY_REGEXOPTIONS];
    
    //now make them into YTDictionary entries
    
    self.latestKeyword = keyword;
    
    for (int i = 0; i < [searchResultsAsStrings count]; i++) {
        [self.latestSearchResults addObject:[self createYTDictionaryEntryFromTextLine:searchResultsAsStrings[i]]];
    }
}

+(NSString *)entryDelimiterAsNSString
{
    return [NSString stringWithFormat:@"%s", YTDICTIONARY_ENTRYDELIM];
}

+(NSString *)sectionDelimterAsNSString
{
    return [NSString stringWithFormat:@"%s", YTDICTIONARY_SECTIONDELIM];
}

-(YTDictionaryEntry *)createYTDictionaryEntryFromTextLine:(NSString *) stringEntry
{
    NSArray * entryAsArray= [stringEntry componentsSeparatedByString:[YTDictionaryManager sectionDelimterAsNSString]];
    YTDictionaryEntry * ytde = [[YTDictionaryEntry alloc] initWithEntryArray:entryAsArray];
    
    return ytde;
    
}

-(void)resetSearchResults
{
    [self.latestSearchResults removeAllObjects];
}




@end
