//
//  TextFileCheckingResult.h
//  YuTone
//
//  Created by Matt on 2/19/14.
//  Copyright (c) 2014 Matt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TextFileCheckingResult : NSObject

//added property
@property (strong, nonatomic) NSNumber * lineNumInTextFile;
@property (nonatomic) NSRange range;

@property (strong, nonatomic) NSURL * sourceURL;

-(instancetype)initWithNSTextCheckingResult:(NSTextCheckingResult *) result;

-(instancetype)initWithLineNum:(NSNumber *)lineNum andRange:(NSRange) range andResourceURL:(NSURL *)URL;


@end
