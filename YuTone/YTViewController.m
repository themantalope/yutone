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

@property (strong, nonatomic) IBOutlet CPTGraphHostingView *hostView;


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

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self initPlot];
    
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
    
    self.audioEngine = [[YTAudioEngine alloc] init];
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


#pragma mark - plot source methods

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return [self.audioEngine.pitchDetector.detectedPitches count];
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)idx
{
    return [self.audioEngine.pitchDetector.detectedPitches objectAtIndex:idx];
}


#pragma mark - plotting view stuff


-(void)initPlot
{
    
    [self configureHost];
    [self configureGraph];
    [self configurePlots];
    [self configureAxes];
}

-(void)configureHost
{
    
    NSLog(@"self.view.bounds.something = %f", self.hostView.bounds.origin.x);
    
    self.hostView.allowPinchScaling = YES;
    
    [self.view addSubview:self.hostView];
    
    
}

-(void)configureGraph
{
    CPTXYGraph * graph = [[CPTXYGraph alloc] initWithFrame:self.hostView.bounds];
    
    [graph applyTheme:[CPTTheme themeNamed:kCPTSlateTheme]];
    
    self.hostView.hostedGraph = graph;
    
    [graph.plotAreaFrame setPaddingLeft:030.0f];
    [graph.plotAreaFrame setPaddingRight:30.0f];
    
    graph.defaultPlotSpace.allowsUserInteraction = YES;
    
    
}

-(void)configurePlots
{
    CPTGraph * graph = self.hostView.hostedGraph;
    
    CPTXYPlotSpace * plotspace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    
    //make a scatter plot
    
    CPTScatterPlot * pitchPlot = [[CPTScatterPlot alloc] init];
    
    pitchPlot.dataSource = self;
    
    UIColor * viewTint = self.view.tintColor;
    
    CGColorRef color = [viewTint CGColor];
    
    CPTColor * plotColor = [CPTColor colorWithCGColor:color];
    
    [plotspace scaleToFitPlots:[NSArray arrayWithObject:pitchPlot]];
    
    CPTMutableLineStyle * linestyle = [pitchPlot.dataLineStyle mutableCopy];
    linestyle.lineWidth = 1.5f;
    linestyle.lineColor = plotColor;
    
}

-(void)configureAxes
{
    
}



#pragma mark - recording
- (IBAction)startRecord:(UIButton *)sender
{
    
    [self.audioEngine beginRecording];
    
}


- (IBAction)stopRecording:(UIButton *)sender
{
    [self.audioEngine endRecording];
    
    //[self initPlot];
}



@end
