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

@property (strong, nonatomic) NSMutableArray * dataForPlot;


@end

@implementation YTViewController

-(NSMutableArray *)dataForPlot
{
    if (!_dataForPlot) {
        _dataForPlot = [[NSMutableArray alloc]init];
    }
    
    return _dataForPlot;
}

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
    
    [self dataVisualization];
    
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
    return [self.audioEngine.detectedPitches count];
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)idx
{
    NSString * key = (fieldEnum == CPTScatterPlotFieldX ? @"x" : @"y");
    NSNumber * num = [[self.dataForPlot objectAtIndex:idx] valueForKey:key];
    //NSLog(@"num : %@ key : %@", num, key);
    return num;
}



#pragma mark - plotting view stuff





#pragma mark - recording
- (IBAction)startRecord:(UIButton *)sender
{
    
    [self.audioEngine beginRecording];
    
}


- (IBAction)stopRecording:(UIButton *)sender
{
    [self.audioEngine endRecording];
    
    [self dataVisualization];
}


-(void)configureDataForPlotWithXData:(NSArray *)xArray andYData:(NSArray *)yArray
{
    if ([xArray count] != [yArray count]) {
        //somethings wrong
        NSLog(@"arrays are not of equal length");
        return;
    }
    else{
        self.dataForPlot = nil;
        
        //make the dictionaries...
        for (int i = 0; i < [xArray count]; i++) {
            NSNumber * x = [xArray objectAtIndex:i];
            NSNumber * y = [yArray objectAtIndex:i];
            
            [self.dataForPlot addObject:[NSDictionary dictionaryWithObjectsAndKeys:x,@"x",y,@"y", nil]];
        }
        
    }
}

#pragma  mark - new graph setup

-(void)dataVisualization
{
    
    self.hostView.allowPinchScaling = YES;
    
    self.hostView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    
    [self.view addSubview:self.hostView];
    
    [self configureDataForPlotWithXData:[self.audioEngine.detectedPitchesTimes copy] andYData:[self.audioEngine.detectedPitches copy]];

    
    CPTXYGraph * graph = [[CPTXYGraph alloc] initWithFrame:self.hostView.bounds];
    
    self.hostView.hostedGraph = graph;
    
    
    
    CPTXYPlotSpace * plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    float yMin = [self findMinNSNumberInArray:self.audioEngine.detectedPitches];
    float yMax = [self findMaxNSNumberInArray:self.audioEngine.detectedPitches];
    float xMax = [self findMaxNSNumberInArray:self.audioEngine.detectedPitchesTimes];
    
    
    
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0f) length:CPTDecimalFromFloat(xMax)];
    
    
    
    
    
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(yMin) length:CPTDecimalFromFloat(yMax)];
    
    CPTMutableLineStyle * linestyle = [CPTMutableLineStyle lineStyle];
    
    CGColorRef sysColor = [self.view.tintColor CGColor];
    
    linestyle.lineColor = [[CPTColor alloc] initWithCGColor:sysColor];
    
    linestyle.lineWidth = 1.5f;
    
    //get the axes
    
    CPTXYAxisSet * axisSet = (CPTXYAxisSet *)graph.axisSet;
    
    axisSet.xAxis.majorIntervalLength = CPTDecimalFromFloat(0.1f);
    axisSet.xAxis.minorTicksPerInterval = 4;
    axisSet.xAxis.majorTickLineStyle = linestyle;
    axisSet.xAxis.minorTickLineStyle = linestyle;
    axisSet.xAxis.axisLineStyle = linestyle;
    axisSet.xAxis.majorTickLength = 5.0f;
    axisSet.xAxis.minorTickLength = 3.0f;
    axisSet.xAxis.labelOffset = 3.0f;
    
    axisSet.yAxis.majorIntervalLength = CPTDecimalFromFloat(10.0f);
    axisSet.yAxis.minorTicksPerInterval = 4;
    axisSet.yAxis.majorTickLineStyle = linestyle;
    axisSet.yAxis.minorTickLineStyle = linestyle;
    axisSet.yAxis.axisLineStyle = linestyle;
    axisSet.yAxis.majorTickLength = 5.0f;
    axisSet.yAxis.minorTickLength = 3.0f;
    axisSet.yAxis.labelOffset = 3.0f;
    
    //add the plot
    
    
    CPTScatterPlot * pitchPlot = [[CPTScatterPlot alloc] initWithFrame:self.hostView.bounds];
    
    pitchPlot.identifier = @"Pitch Plot";
    CPTMutableLineStyle * plotLineStyle = (CPTMutableLineStyle *)pitchPlot.dataLineStyle;
    plotLineStyle.lineWidth = 1.0f;
    plotLineStyle.lineColor = [[CPTColor alloc] initWithCGColor:sysColor];
    pitchPlot.dataSource = self;
    [graph addPlot:pitchPlot];
    
    
    
    [graph reloadData];
    
    
    
    
    
    
}


-(float)findMaxNSNumberInArray:(NSArray *)array
{
    float max = 0.0f;
    
    for (int i = 0; i < [array count]; i++) {
        if ([[array objectAtIndex:i] isKindOfClass:[NSNumber class]]) {
            float current = [[array objectAtIndex:i] floatValue];
            if (current > max) {
                max = current;
            }
        }
    }
    
    return max;
}

-(float)findMinNSNumberInArray:(NSArray *)array
{
    float min = 0.0f;
    
    for (int i = 0; i < [array count]; i++) {
        if ([[array objectAtIndex:i] isKindOfClass:[NSNumber class]]) {
            float current = [[array objectAtIndex:i] floatValue];
            if (current < min) {
                min = current;
            }
        }
    }
    
    return min;
}


@end
