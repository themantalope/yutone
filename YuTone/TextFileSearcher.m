//
//  TextFileSearcher.m
//  YuTone
//
//  Created by Matt on 2/19/14.
//  Copyright (c) 2014 Matt. All rights reserved.
//

#import "TextFileSearcher.h"
#import "TextFileCheckingResult.h"

@implementation TextFileSearcher




+(NSURL *)convertFilePathToNSURL:(NSString *)filePath
{
    NSURL * fURL = [NSURL fileURLWithPath:filePath];
    return fURL;
}

+(NSURL *)getURLforFileWithName:(NSString *)fileName andExtension:(NSString *)ext
{
    NSString * filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:ext];
    NSURL * fURL = [TextFileSearcher convertFilePathToNSURL:filePath];
    return fURL;
}

-(NSArray *)getTextFileCheckingResultsForKeyword:(NSString *)keyword forURL:(NSURL *)URL withRegExOptions:(NSRegularExpressionOptions) options withEncoding:(NSStringEncoding) encoding{
    
    
    NSArray * entries = [self getTextFileEntriesForURL:URL withEncoding:encoding withDelimiter:@"\n"];
    
    
    NSArray * results = [self getTextFileCheckingResultsForKeyword:keyword forTextFileEntries:entries withRegExOptions:options];
    
    
    for (int i = 0; i < [results count]; i++) {
        [[results objectAtIndex:i] setSourceURL:URL];
    }
    
    return results;
    
}


-(NSArray *)getTextFileCheckingResultsForKeyword:(NSString *)keyword forFile:(NSString *)filePath withRegExOptions:(NSRegularExpressionOptions)options withEncoding:(NSStringEncoding)encoding
{
    
    NSURL * url = [TextFileSearcher convertFilePathToNSURL:filePath];
    
    return [self getTextFileCheckingResultsForKeyword:keyword forURL:url withRegExOptions:options withEncoding:encoding];
    
    
}

-(NSArray *)getTextFileEntriesForURL:(NSURL *)URL withEncoding:(NSStringEncoding) encoding withDelimiter:(NSString *)delim
{
    NSError * err = NULL;
    
    //get info from file
    
    NSString * fileContents = [NSString stringWithContentsOfURL:URL encoding:encoding error:&err];
    
    if (err) {
        NSLog(@"error getting file contents : %@", err);
        return @[];
    }
    NSArray * parts = [fileContents componentsSeparatedByString:delim];
    
    return parts;
}

-(NSArray *)getTextFileCheckingResultsForKeyword:(NSString *)keyword forTextFileEntries:(NSArray *) entries withRegExOptions:(NSRegularExpressionOptions)options
{
    
    
    NSMutableArray * results = [[NSMutableArray alloc] init];
    
    NSString * searchPattern = [NSString stringWithFormat:@"\\b%@\\b", keyword];
    
    NSError * err = NULL;
    
    
    NSRegularExpression * regex = [NSRegularExpression regularExpressionWithPattern:searchPattern options:options error:&err];
    
    if (err) {
        NSLog(@"error getting regex : %@", err);
        return @[];
    }
    
    for (int i = 0; i < [entries count]; i++) {
        //do the search
        
        NSArray * matches = [regex matchesInString:entries[i] options:0 range:NSMakeRange(0, [entries[i] length])];
        
        if ([matches count] > 0) {
            //we have something
            //make a textfile
            //checkingresult object and
            // add it
            
            for (int j = 0; j < [matches count]; j++) {
                //create the result
                
                NSTextCheckingResult * curRes = matches[j];
                
                TextFileCheckingResult * curTFRes = [[TextFileCheckingResult alloc] initWithNSTextCheckingResult:curRes];
                
                curTFRes.lineNumInTextFile = [NSNumber numberWithInt:i];
                
                [results addObject:curTFRes];
                
                
            }
            
        }
    }
    
    
    return [results copy];

}






@end
