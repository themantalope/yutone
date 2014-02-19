//
//  YTDictionaryManager.h
//  YuTone
//
//  Created by Matt on 2/19/14.
//  Copyright (c) 2014 Matt. All rights reserved.
//

#import "DictionarySearcher.h"

@interface YTDictionaryManager : DictionarySearcher

@property (strong, nonatomic) NSMutableArray * latestSearchResults;

-(instancetype)initWithDictionaryURL:(NSURL *)URL;

-(void)getEntriesForKeyword:(NSString *)keyword;

@end
