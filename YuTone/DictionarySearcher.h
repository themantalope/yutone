//
//  DictionarySearcher.h
//  YuTone
//
//  Created by Matt on 2/19/14.
//  Copyright (c) 2014 Matt. All rights reserved.
//

#import "TextFileSearcher.h"

@interface DictionarySearcher : TextFileSearcher

-(NSArray *)getDictionaryEntriesForKeyword:(NSString *)keyword withEntryDelimiter:(NSString *)delim forURL:(NSURL *) URL withEncoding:(NSStringEncoding) encoding withRegExOptions:(NSRegularExpressionOptions) options;


@end
