//
//  TextFileSearcher.h
//  YuTone
//
//  Created by Matt on 2/19/14.
//  Copyright (c) 2014 Matt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TextFileSearcher : NSObject



-(NSArray *)getTextFileCheckingResultsForKeyword:(NSString *)keyword forFile:(NSString *)filePath withRegExOptions:(NSRegularExpressionOptions) options withEncoding:(NSStringEncoding) encoding;

-(NSArray *)getTextFileCheckingResultsForKeyword:(NSString *)keyword forURL:(NSURL *)URL withRegExOptions:(NSRegularExpressionOptions) options withEncoding:(NSStringEncoding) encoding;

+(NSURL *)convertFilePathToNSURL:(NSString *)filePath;
+(NSURL *)getURLforFileWithName:(NSString *)fileName andExtension:(NSString *)ext;

-(NSArray *)getTextFileEntriesForURL:(NSURL *)URL withEncoding:(NSStringEncoding) encoding withDelimiter:(NSString *)delim;

-(NSArray *)getTextFileCheckingResultsForKeyword:(NSString *)keyword forTextFileEntries:(NSArray *) entries withRegExOptions:(NSRegularExpressionOptions)options;



@end
