//
//  SearchResultsTableVC.m
//  YuTone
//
//  Created by Matt on 2/20/14.
//  Copyright (c) 2014 Matt. All rights reserved.
//

#import "SearchResultsTableVC.h"
#import "YTDictionaryManager.h"
#import "YTDictionaryEntry.h"
#import "YTViewController.h"




#define CELL_ID @"YTDictionaryCell"
#define NUMBER_OF_SECTIONS 1
#define CELL_PUSH_SEGUE_ID @"cellPushSegue"
#define PRACTICE_PUSH_SEGUE_ID @"practiceButtonPushSegue"
#define DOT_SYMBOL @"●"
#define DICTIONARY_NAME @"cedict_ts_wpym.u8"
#define DICTIONARY_EXT @"starsv"


@interface SearchResultsTableVC ()

@property (strong, nonatomic) YTDictionaryManager * dictionaryManager;

@end

@implementation SearchResultsTableVC


-(YTDictionaryManager *)dictionaryManager
{
    if (!_dictionaryManager) {
        
        NSURL * url = [YTDictionaryManager getURLforFileWithName:DICTIONARY_NAME andExtension:DICTIONARY_EXT];
        
        _dictionaryManager = [[YTDictionaryManager alloc] initWithDictionaryURL:url];
    }
    
    return _dictionaryManager;
}

-(void)setDictionaryEntries:(NSArray *)dictionaryEntries
{
    _dictionaryEntries = dictionaryEntries;
    [self.tableView reloadData];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    
    self.searchDisplayController.searchBar.delegate = self;
    self.searchDisplayController.delegate = self;
    
    [self.searchDisplayController.searchResultsTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CELL_ID];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
// #warning Potentially incomplete method implementation.
    // Return the number of sections.
    return NUMBER_OF_SECTIONS;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return [self.dictionaryEntries count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = CELL_ID;
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    //first get the dictionary entry
    YTDictionaryEntry * entry = self.dictionaryEntries[indexPath.row];
    
    printf("I'm in the cell config fcn..\n");
    // Configure the cell...
    
    NSString * title = [NSString stringWithFormat:@"%@ %@ %@ : %@", entry.simplified, DOT_SYMBOL, entry.traditional, entry.pinyinWithMarks];
    
    NSString * detailed = [NSString stringWithFormat:@" %@ ", entry.definitions];
    
    //now check to see where the latest search word was
    
    NSRange keywordRange = [self getNSRangeOfKeyword:self.dictionaryManager.latestKeyword forString:title];
    
    bool keywordInTitle = true;
    
    if (keywordRange.location == NSNotFound) {
        keywordRange = [self getNSRangeOfKeyword:self.dictionaryManager.latestKeyword forString:detailed];
        
        keywordInTitle = false;
    }
    
    NSMutableAttributedString * attTitle = [[NSMutableAttributedString alloc] initWithString:title];
    
    NSMutableAttributedString * attDetailed = [[NSMutableAttributedString alloc] initWithString:detailed];
    
    if (keywordInTitle) {
        [attTitle addAttribute:NSForegroundColorAttributeName value:tableView.tintColor range:keywordRange];
    }
    else{
        [attDetailed addAttribute:NSForegroundColorAttributeName value:tableView.tintColor range:keywordRange];
    }
    
    
    //now we can set the cell
    
    cell.textLabel.attributedText = [attTitle attributedSubstringFromRange:NSMakeRange(0, [attTitle length])];
    
    cell.detailTextLabel.attributedText = [attDetailed attributedSubstringFromRange:NSMakeRange(0, [attDetailed length])];
    
    return cell;
}

-(NSRange)getNSRangeOfKeyword:(NSString *)keyword forString:(NSString *)string
{
    NSRange range = [string rangeOfString:keyword options:(NSCaseInsensitiveSearch | NSWidthInsensitiveSearch)];
    
    return range;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

//helper prep method

-(void)prepareYTViewController:(YTViewController *)ytvc withDictionaryEntry:(YTDictionaryEntry *)entry
{
    ytvc.entry = entry;
    
    
    [ytvc configureDisplayText];
    

}




// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        
        
        NSIndexPath * idxPath = [self.tableView indexPathForCell:sender];
        
        
            if ([segue.identifier isEqualToString:CELL_PUSH_SEGUE_ID]) {
                if ([segue.destinationViewController isKindOfClass:[YTViewController class]]) {
                    [self prepareYTViewController:segue.destinationViewController withDictionaryEntry:[self.dictionaryEntries objectAtIndex:idxPath.row]];
                }
            }
        }
    
}


#pragma mark - searching




-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    
    UIActivityIndicatorView * spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.hidesWhenStopped = YES;
    spinner.center = self.searchDisplayController.searchBar.center;
    
    [self.searchDisplayController.searchBar addSubview:spinner];
    [spinner startAnimating];
    
    dispatch_queue_t queue = dispatch_queue_create("com.dictionary.search", NULL);
    dispatch_async(queue, ^{
        
        
        [self.dictionaryManager getEntriesForKeyword:self.searchDisplayController.searchBar.text];
        
        self.dictionaryEntries = [self.dictionaryManager.latestSearchResults copy];
        
        printf("num of results : %d\n", [self.dictionaryEntries count]);
        
        NSLog(@"%@", [[self.dictionaryEntries objectAtIndex:0] simplified]);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [spinner stopAnimating];
            
            [self.searchDisplayController.searchResultsTableView reloadData];
        
        
        });
    
    
    });
    
    
    
}






@end
