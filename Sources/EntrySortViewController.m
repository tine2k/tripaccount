//
//  EntrySortViewController.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 25/07/2011.
//  Copyright 2011 Martin Maier. All rights reserved.
//

#import "EntrySortViewController.h"
#import "UIFactory.h"
#import "ReiseabrechnungAppDelegate.h"
#import "Currency.h"

@implementation EntrySortViewController

@synthesize travel=_travel, detailViewController=_detailViewController, segControl=_segControl;

- (id)initWithTravel:(Travel *)travel {
    
    if (self = [super init]) {
        self.travel = travel;
        
        EntryViewController *evc = [[EntryViewController alloc] initWithTravel:travel];
        self.detailViewController = evc;
        evc.delegate = self;
        [evc release];
        
        self.title = @"Expenses";
        
        if ([[ReiseabrechnungAppDelegate defaultCurrency:[travel managedObjectContext]].code isEqualToString:@"USD"]) {
            
            self.tabBarItem.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"pricetag" ofType:@"png"]];            
        } else {
            
            self.tabBarItem.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"pricetag_euro" ofType:@"png"]];
        }
    }
    return self;
}

- (void)sortTable:(UISegmentedControl *)sender {
    [self.detailViewController sortTable:sender.selectedSegmentIndex];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark - EntryViewControllerDelegate

- (void)didItemCountChange:(NSUInteger)itemCount {
    if (itemCount == 0) {
        self.tabBarItem.badgeValue = nil;
    } else {
        self.tabBarItem.badgeValue = [NSString stringWithFormat:@"%d", itemCount];
    }   
}

#pragma mark - View lifecycle

#define CURRENCY_SORT_TOOLBAR_HEIGHT 40

- (void)loadView {
    
    [super loadView];

    NSArray *segArray = [NSArray arrayWithObjects:@"Person", @"Type", @"Date", nil];
    UISegmentedControl *segControl = [[UISegmentedControl alloc] initWithItems:segArray]; 
    segControl.frame = CGRectMake(5, 5, [UIScreen mainScreen].applicationFrame.size.width - 10, CURRENCY_SORT_TOOLBAR_HEIGHT - 10);
    [segControl addTarget:self action:@selector(sortTable:) forControlEvents:UIControlEventValueChanged];
    segControl.segmentedControlStyle = UISegmentedControlStyleBezeled;
    segControl.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin |UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    segControl.tintColor = [UIFactory defaultTintColor];
    self.segControl = segControl;
    
    self.segControl.selectedSegmentIndex = [self.travel.displaySort intValue];
    
    UIView *segControlView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].applicationFrame.size.width, CURRENCY_SORT_TOOLBAR_HEIGHT)];
    [segControlView addSubview:segControl];
    self.detailViewController.tableView.tableHeaderView = segControlView;
    [segControlView release];
    
    self.detailViewController.view.frame = CGRectMake(0, 0, [UIScreen mainScreen].applicationFrame.size.width, [[UIScreen mainScreen] applicationFrame].size.height - TABBAR_HEIGHT);
    self.detailViewController.tableView.contentInset = UIEdgeInsetsMake(NAVIGATIONBAR_HEIGHT, 0, 0, 0);
    self.detailViewController.tableView.scrollIndicatorInsets = self.detailViewController.tableView.contentInset;
    
    self.view = self.detailViewController.view;

}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark Memory management

- (void)dealloc {
    [super dealloc];
}

@end
