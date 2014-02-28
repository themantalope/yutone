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
    NSLog(@"num : %@ key : %@", num, key);
    return num;
}



#pragma mark - plotting view stuff


-(void)initPlot
{
    [self configureDataForPlotWithXData:self.audioEngine.detectedPitchesTimes andYData:self.audioEngine.detectedPitches];
    [self configureHost];
    [self configureGraph];
    [self configurePlots];
    [self configureAxes];
}

-(void)configureHost
{
    
    NSLog(@"self.view.bounds.something = %f", self.hostView.bounds.origin.x);
    
    self.hostView.allowPinchScaling = YES;
    
    self.hostView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    
    [self.view addSubview:self.hostView];
    
    
}

-(void)configureGraph
{
    CPTXYGraph * graph = [[CPTXYGraph alloc] initWithFrame:self.hostView.bounds];
    
    [graph applyTheme:[CPTTheme themeNamed:kCPTPlainWhiteTheme]];
    
    
    
    [graph.plotAreaFrame setPaddingLeft:0.0f];
    [graph.plotAreaFrame setPaddingRight:0.0f];
    [graph.plotAreaFrame setPaddingTop:0.0f];
    [graph.plotAreaFrame setPaddingBottom:0.0f];
    
    graph.defaultPlotSpace.allowsUserInteraction = YES;
    
    
    
    self.hostView.hostedGraph = graph;
}

-(void)configurePlots
{
    CGFloat xMax = [[self.audioEngine.detectedPitchesTimes valueForKeyPath:@"@max.self"] floatValue] + 0.0f;
    CPTGraph * graph = self.hostView.hostedGraph;
    
    CPTXYPlotSpace * plotspace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    
    //make a scatter plot
    
    CPTScatterPlot * pitchPlot = [[CPTScatterPlot alloc] init];
    
    pitchPlot.dataSource = self;
    pitchPlot.dataLineStyle = [CPTMutableLineStyle lineStyle];
    
    UIColor * viewTint = self.view.tintColor;
    
    CGColorRef color = [viewTint CGColor];
    
    
    CPTColor * plotColor = [CPTColor colorWithCGColor:color];
    
    plotspace.xRange = [[CPTPlotRange alloc] initWithLocation:CPTDecimalFromFloat(0.0) length:CPTDecimalFromFloat(xMax)];
//    plotspace.yRange = [[CPTPlotRange alloc] initWithLocation:CPTDecimalFromCGFloat(yMin) length:CPTDecimalFromFloat(yMax - yMin)];

    //[plotspace scaleToFitPlots:@[pitchPlot]];
    
    CPTMutableLineStyle * linestyle = [pitchPlot.dataLineStyle mutableCopy];
    linestyle.lineWidth = 2.0f;
    linestyle.lineColor = plotColor;
    
    [graph addPlot:pitchPlot];
    
}

-(void)configureAxes
{
    //first create the styles for the text
    
    CPTMutableTextStyle * axisStyle = [CPTMutableTextStyle textStyle];
    
    CGColorRef sysColor = [self.view.tintColor CGColor];
    
    axisStyle.color = [[CPTColor alloc] initWithCGColor:sysColor];
    
    axisStyle.fontSize = 12.0f;
    
    CPTMutableLineStyle *axisLineStyle = [CPTMutableLineStyle lineStyle];
    
    axisLineStyle.lineWidth = 1.5f;
    
    axisLineStyle.lineColor = [[CPTColor alloc] initWithCGColor:sysColor];
    
    CPTMutableTextStyle * axisTextStyle = [[CPTMutableTextStyle alloc] init];
    
    axisTextStyle.color = [[CPTColor alloc] initWithCGColor:sysColor];
    
    axisTextStyle.fontSize = 12.0f;
    
    CPTMutableLineStyle * tickLineStyle = [CPTMutableLineStyle lineStyle];
    
    tickLineStyle.lineColor = [[CPTColor alloc] initWithCGColor:sysColor];
    
    tickLineStyle.lineWidth = 2.0f;
    
    CPTMutableLineStyle * gridLineStyle = [CPTMutableLineStyle lineStyle];
    
    gridLineStyle.lineColor = [CPTColor grayColor];
    gridLineStyle.lineWidth = 0.5f;
    
    
    //get the axis set
    
    CPTXYAxisSet * axisSet = (CPTXYAxisSet *) self.hostView.hostedGraph.axisSet;
    
    //configure x-axis
    
    CPTAxis * x = axisSet.xAxis;
    
    x.title = @"Time (s)";
    x.titleTextStyle = axisTextStyle;
    x.titleOffset = 10.0f;
    x.axisLineStyle = axisLineStyle;
    x.labelingPolicy = CPTAxisLabelingPolicyNone;
    x.labelTextStyle = axisTextStyle;
    x.majorTickLineStyle = axisLineStyle;
    x.majorTickLength = 4.0f;
    x.majorIntervalLength = CPTDecimalFromFloat(0.1f);
    x.tickDirection = CPTSignNegative;
    
    CGFloat timeCount = [self.audioEngine.detectedPitchesTimes count];
    
    NSMutableSet * xLabels = [NSMutableSet setWithCapacity:timeCount];
    NSMutableSet * xLocations = [NSMutableSet setWithCapacity:timeCount];
    
    for (int i = 0; i < (int) timeCount; i++) {
        //create a label
        
        CPTAxisLabel * label = [[CPTAxisLabel alloc] initWithText:[NSString stringWithFormat:@"%@",[self.audioEngine.detectedPitchesTimes objectAtIndex:i] ] textStyle:x.labelTextStyle];
        
        NSNumber * loc = [NSNumber numberWithInt:i];
        
        CGFloat location = [loc floatValue];
        label.tickLocation = CPTDecimalFromCGFloat(location);
        label.offset = x.majorTickLength;
        if (label) {
            //add it to our lists
            [xLabels addObject:label];
            [xLocations addObject:[NSNumber numberWithFloat:location]];
        }
    }
    
    x.axisLabels = xLabels;
    x.majorTickLocations = xLocations;
    
    //congfigure the y-axis
    
    CPTAxis * y = axisSet.yAxis;
    y.title = @"Frequency (Hz)";
    y.titleTextStyle = axisTextStyle;
    y.titleOffset = -40.0f;
    y.axisLineStyle = axisLineStyle;
    y.labelingPolicy = CPTAxisLabelingPolicyNone;
    y.labelTextStyle = axisTextStyle;
    y.labelOffset = 16.0f;
    y.majorTickLineStyle = axisLineStyle;
    y.majorTickLength = 4.0f;
    y.tickDirection = CPTSignPositive;
    NSInteger majorIncrement = 1;
    CGFloat yMax = [[self.audioEngine.detectedPitches valueForKeyPath:@"@max.self"] floatValue] + 10.0f;
    CGFloat yMin = [[self.audioEngine.detectedPitches valueForKeyPath:@"@min.self"] floatValue] - 10.0f;
    
    int yMinInt = [[NSNumber numberWithFloat:yMin] intValue];
    int yMaxInt = [[NSNumber numberWithFloat:yMax] intValue];
    
    NSMutableSet * yLocations = [NSMutableSet set];
    NSMutableSet * yLabels = [NSMutableSet set];
    
    for (int i = yMinInt; i <= yMaxInt; i+= majorIncrement) {
        CPTAxisLabel * label = [[CPTAxisLabel alloc] initWithText:[NSString stringWithFormat:@"%d",i] textStyle:y.labelTextStyle];
        CGFloat location = (float) i;
        label.tickLocation = CPTDecimalFromCGFloat(location);
        label.offset = -y.majorTickLength - y.labelOffset;
        if (label) {
            [yLabels addObject:label];
            [yLocations addObject:[NSNumber numberWithFloat:location]];
        }
        
        y.axisLabels = yLabels;
        y.majorTickLocations = yLocations;
        
    }
    
    
    
    
}



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
        
        self.dataForPlot = [[NSMutableArray alloc] init];
        
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
    
    [self configureDataForPlotWithXData:self.audioEngine.detectedPitchesTimes andYData:self.audioEngine.detectedPitches];
    
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
