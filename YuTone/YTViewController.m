//
//  YTViewController.m
//  YuTone
//
//  Created by Matt on 1/23/14.
//  Copyright (c) 2014 Matt. All rights reserved.
//

#import "YTViewController.h"
#import "YTAudioEngine.h"



#define DOT_SYMBOL @"●"

@interface YTViewController ()
@property (weak, nonatomic) IBOutlet UITextView *textInfoDisplay;

@property (nonatomic) YTAudioEngine * audioEngine;

@end

@implementation YTViewController

-(YTAudioEngine *)audioEngine
{
    if (!_audioEngine) {
        _audioEngine = [[YTAudioEngine alloc] init];
    }
    
    return _audioEngine;
}


-(YTDictionaryEntry *)entry
{
    if (!_entry) {
        _entry = [[YTDictionaryEntry alloc] init];
    }
    
    return _entry;
}

-(NSMutableAttributedString *)displayText
{
    if (!_displayText) {
        _displayText = [[NSMutableAttributedString alloc] init];
    }
    
    return _displayText;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    
    [self updateUI];
}

-(void)updateUI
{
    self.textInfoDisplay.attributedText = [self.displayText attributedSubstringFromRange:NSMakeRange(0, [self.displayText length])];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.textInfoDisplay.delegate = self;
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)configureDisplayText
{
    NSMutableAttributedString * characters = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@ %@\n\n", [self.entry simplified], DOT_SYMBOL, [self.entry traditional]]];
    
    NSMutableAttributedString * pinyin = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n\n", [self.entry pinyinWithMarks]]];
    
    NSMutableAttributedString * definitions = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", [self.entry definitions]]];
    
    
    [characters addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:24.0] range:NSMakeRange(0, [characters length])];
    
    [pinyin addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:24.0] range:NSMakeRange(0, [pinyin length])];
    
    [definitions addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16.0] range:NSMakeRange(0, [definitions length])];
    
    self.displayText = characters;
    
    [self.displayText appendAttributedString:[pinyin copy]];
    [self.displayText appendAttributedString:[definitions copy]];
    
    [self updateUI];
    
}


+(NSMutableAttributedString *)defaultTextDisplay
{
    NSMutableAttributedString * text = [[NSMutableAttributedString alloc] init];
    
    NSMutableAttributedString * characters = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@ %@\n\n",@"你好", DOT_SYMBOL, @"你好"]];
    
    NSMutableAttributedString * pinyin = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n\n", @" nĭ haŏ "]];
    
    NSMutableAttributedString * definitions = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",@" Hello!; Hi!; How are you?"]];
    
    [characters addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:24.0] range:NSMakeRange(0, [characters length])];
    
    [pinyin addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:24.0] range:NSMakeRange(0, [pinyin length])];
    
    [definitions addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16.0] range:NSMakeRange(0, [definitions length])];
    
    [text appendAttributedString:characters];
    [text appendAttributedString:pinyin];
    
    [text appendAttributedString:definitions];
    
    return [text copy];
}


@end
