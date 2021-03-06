//
//  SummaryViewController.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 30/06/2011.
//  Copyright 2011 Martin Maier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Travel.h"
#import "Summary.h"
#import "SummaryCell.h"
#import "CoreDataTableViewController.h"


@interface SummaryViewController : CoreDataTableViewController {

}

@property (nonatomic, retain) Travel *travel;
@property (nonatomic, assign) IBOutlet SummaryCell *summaryCell;

- (id)initWithTravel:(Travel *) travel;
- (void)recalculateSummary;

- (void)changeDisplayedCurrency:(Currency *)currency;

@end
