//
//  SearchResultsTableVC.h
//  YuTone
//
//  Created by Matt on 2/20/14.
//  Copyright (c) 2014 Matt. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchResultsTableVC : UITableViewController <UISearchBarDelegate, UISearchDisplayDelegate>

@property (strong, nonatomic) NSArray * dictionaryEntries;

@end
