//
//  DictionarySearcher.m
//  YuTone
//
//  Created by Matt on 2/19/14.
//  Copyright (c) 2014 Matt. All rights reserved.
//

#import "DictionarySearcher.h"
#import "TextFileCheckingResult.h"

@implementation DictionarySearcher


-(NSArray *)getDictionaryEntriesForKeyword:(NSString *)keyword withEntryDelimiter:(NSString *)delim forURL:(NSURL *) URL withEncoding:(NSStringEncoding) encoding withRegExOptions:(NSRegularExpressionOptions) options
{
    
    NSArray * allEntries = [self getTextFileEntriesForURL:URL withEncoding:encoding withDelimiter:delim];
    
    NSArray * matchResults = [self getTextFileCheckingResultsForKeyword:keyword forTextFileEntries:allEntries withRegExOptions:options];
    
    NSMutableArray * matchedEntries = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [matchResults count]; i++) {
        //add them in
        
        
        
        NSNumber * num = [[matchResults objectAtIndex:i] lineNumInTextFile];
        
        [matchedEntries addObject:[allEntries objectAtIndex:[num integerValue]]];
    }
    
    return [matchedEntries copy];
}


@end
