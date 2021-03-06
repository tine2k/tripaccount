//
//  SummaryViewController.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 30/06/2011.
//  Copyright 2011 Martin Maier. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "SummaryViewController.h"
#import "Summary.h"
#import "Participant.h"
#import "SummaryCell.h"
#import "UIFactory.h"
#import "CurrencyHelperCategory.h"
#import "Transfer.h"
#import "ReiseabrechnungAppDelegate.h"
#import "ImageCache.h"

@implementation SummaryViewController

@synthesize travel=_travel, summaryCell=_summaryCell ;

- (id)initWithTravel:(Travel *) travel {
    
    [Crittercism leaveBreadcrumb:@"SummaryViewController: init"];

    if (self = [super initWithStyle:UITableViewStylePlain]) {
    
        self.travel = travel;
        
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        
        [UIFactory initializeTableViewController:self.tableView];
        
        UIEdgeInsets insets = self.tableView.contentInset;
        insets.top = NAVIGATIONBAR_HEIGHT;
        self.tableView.contentInset = insets;
        self.tableView.scrollIndicatorInsets = self.tableView.contentInset;
        
        NSFetchRequest *req = [[NSFetchRequest alloc] init];
        req.entity = [NSEntityDescription entityForName:@"Transfer" inManagedObjectContext:[travel managedObjectContext]];
        req.sortDescriptors = [NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"debtor.name" ascending:YES selector:@selector(caseInsensitiveCompare:)], [NSSortDescriptor sortDescriptorWithKey:@"debtee.name" ascending:YES selector:@selector(caseInsensitiveCompare:)], nil];
        req.predicate = [NSPredicate predicateWithFormat:@"travel = %@", travel];
        
        self.fetchedResultsController = [[[NSFetchedResultsController alloc] initWithFetchRequest:req managedObjectContext:[travel managedObjectContext] sectionNameKeyPath:nil cacheName:nil] autorelease];
        [req release];
        
        self.fetchedResultsController.delegate = self;
        [self performFetchForTableView:self.tableView];
       
        [self viewWillAppear:YES];
    }
    return self;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForManagedObject:(NSManagedObject *)managedObject {
    
    static NSString *ReuseIdentifier = @"SummaryCell";
    
    SummaryCell *cell = (SummaryCell *) [tableView dequeueReusableCellWithIdentifier:ReuseIdentifier];
    if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"SummaryCell" owner:self options:nil];
        
        cell = self.summaryCell;
        [UIFactory initializeCell:cell];
        
        cell.paid.layer.cornerRadius = 4;
        cell.paid.layer.masksToBounds = YES;
        [UIFactory addGradientToView:cell.paid color1:[UIColor colorWithRed:1 green:0.2 blue:0.2 alpha:1] color2:[UIColor colorWithRed:0.5 green:0 blue:0 alpha:1]];
        cell.paid.alpha = 0.7;
        cell.paidLabel.text = NSLocalizedString(@"PAID", @"red label uppercase");
    }
    
    cell.owes.text = NSLocalizedString(@"owes", @"owes");
    cell.to.text = NSLocalizedString(@"(owes) to", @"owes 'to'");
    
    Transfer *transfer = (Transfer *)managedObject;

    cell.debtor.text = transfer.debtor.name;
    cell.leftImage.image = [[ImageCache instance] getImage:transfer.debtor.image];
    cell.debtee.text = transfer.debtee.name;
    cell.rightImage.image = [[ImageCache instance] getImage:transfer.debtee.image];
    cell.amount.text = [NSString stringWithFormat:@"%@ %@", [UIFactory formatNumber:[transfer amountInDisplayCurrency]], self.travel.displayCurrency.code];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.paid.hidden = YES;
    
    cell.rightImage.alpha = 1;
    cell.leftImage.alpha = 1;
    
    UIColor *textColor = [UIColor blackColor];
    if ([self.travel isClosed]) {
        textColor = [UIColor grayColor];
        cell.rightImage.alpha = 0.6;
        cell.leftImage.alpha = 0.6;
    }
    
    if ([self.travel isClosed] && [transfer.paid intValue] == 1) {
       cell.paid.hidden = NO; 
    }

    cell.debtor.textColor = textColor;
    cell.debtee.textColor = textColor;
    cell.amount.textColor = textColor;
    cell.owes.textColor = textColor;
    cell.to.textColor = textColor;
    
    
    return cell;    
}

- (void)managedObjectSelected:(NSManagedObject *)managedObject {
    
    [Crittercism leaveBreadcrumb:@"SummaryViewController: managedObjectSelected"];
   
    Transfer *transfer = (Transfer *)managedObject;
    
    if ([self.travel isClosed]) {
        
        if ([transfer wasPaid]) {
            transfer.paid = [NSNumber numberWithInt:0];
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[[self fetchedResultsControllerForTableView:self.tableView] indexPathForObject:managedObject]] withRowAnimation:UITableViewRowAnimationLeft];
        } else {
            transfer.paid = [NSNumber numberWithInt:1];
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[[self fetchedResultsControllerForTableView:self.tableView] indexPathForObject:managedObject]] withRowAnimation:UITableViewRowAnimationRight];
        }
        
        [ReiseabrechnungAppDelegate saveContext:[self.travel managedObjectContext]];
    }
    
    [self.tableView deselectRowAtIndexPath:[[self fetchedResultsControllerForTableView:self.tableView] indexPathForObject:managedObject]  animated:YES];
}

- (void)changeDisplayedCurrency:(Currency *)currency {
    
    self.travel.displayCurrency = currency;
    [ReiseabrechnungAppDelegate saveContext:[self.travel managedObjectContext]];
    
    [self.tableView reloadData];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 64;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark Business Logic

- (void)recalculateSummary {
    
    [Crittercism leaveBreadcrumb:@"SummaryViewController: recalculateSummary"];

    if ([self.travel isOpen]) {
        
        [Summary updateSummaryOfTravel:self.travel];
    }
}


#pragma mark - View lifecycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload {
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark - Memory management

- (void)dealloc {
    [_travel release];
    [super dealloc];
}

@end
