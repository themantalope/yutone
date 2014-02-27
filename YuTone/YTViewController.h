//
//  YTViewController.h
//  YuTone
//
//  Created by Matt on 1/23/14.
//  Copyright (c) 2014 Matt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YTDictionaryEntry.h"
#import "CorePlot-CocoaTouch.h"


@interface YTViewController : UIViewController <UITextViewDelegate, CPTPlotDataSource>

@property (strong, nonatomic) YTDictionaryEntry * entry;

@property (strong, nonatomic) NSMutableAttributedString * displayText;

-(void)configureDisplayText;

@end
