//
//  EntryViewController.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 30/06/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EntryViewController.h"
#import "EntryCell.h"
#import "ReiseabrechnungAppDelegate.h"
#import "Currency.h"
#import "Participant.h"
#import "EntryEditViewController.h"
#import "ShadowNavigationController.h"

@interface EntryViewController ()
- (void)initFetchResultsController:(NSFetchRequest *)req;    
@end

@implementation EntryViewController

@synthesize travel=_travel, fetchRequest=_fetchRequest;
@synthesize delegate=_delegate, editDelegate=_editDelegate;

- (id)initWithTravel:(Travel *) travel {
    
    if (self = [super initWithStyle:UITableViewStylePlain]) {
        
        _travel = travel;
        _sortIndex = 0;
        
        _sortKeyArray = [[NSArray alloc] initWithObjects:@"payer.name", @"type.name", @"currency.name", nil];

        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        
        [UIFactory initializeTableViewController:self.tableView];

        NSManagedObjectContext *context = [travel managedObjectContext];
        
        NSFetchRequest *req = [[NSFetchRequest alloc] init];
        req.entity = [NSEntityDescription entityForName:@"Entry" inManagedObjectContext: context];
        req.predicate = [NSPredicate predicateWithFormat:@"travel = %@", travel];
        self.fetchRequest = req;
        [req release];
        
        [self initFetchResultsController:self.fetchRequest];
        
        self.fetchedResultsController.delegate = self;
        
        self.titleKey = @"text";
        self.subtitleKey = @"amount";
        
        [self controllerDidChangeContent:self.fetchedResultsController];
        
        [self viewWillAppear:YES];
    }
    
    return self;
}

- (UITableViewCellAccessoryType)accessoryTypeForManagedObject:(NSManagedObject *)managedObject {
    return UITableViewCellAccessoryNone;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForManagedObject:(NSManagedObject *)managedObject {
    
    static NSString *CellIdentifier = @"EntryCell";
    
    EntryCell *cell = (EntryCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray *tlo = [[NSBundle mainBundle] loadNibNamed:@"EntryCell" owner:self options:nil];
        cell = [tlo objectAtIndex:0];
        [UIFactory initializeCell:cell];
    }
    
    // Set up the cell... 
    Entry *entry = (Entry *) managedObject;
    if (entry.text && [entry.text length] > 0) {
        cell.top.text = entry.text;
    } else {
        cell.top.text = entry.type.name;
    }
    cell.bottom.text = [NSString stringWithFormat:@"for %d people", [entry.receivers count]];
    cell.right.text = [NSString stringWithFormat:@"%@ %@", entry.amount, entry.currency.code];
    
    return cell;
}

- (void)managedObjectSelected:(NSManagedObject *)managedObject {
    
    EntryEditViewController *detailViewController = [[EntryEditViewController alloc] initWithTravel:_travel andEntry:(Entry *) managedObject target:self.editDelegate action:@selector(addOrEditEntryWithParameters:andEntry:)];
    UINavigationController *navController = [[ShadowNavigationController alloc] initWithRootViewController:detailViewController];
    navController.delegate = detailViewController;
    [self presentModalViewController:navController animated:YES];   
    [detailViewController release];
    [navController release];
    
    [self.tableView deselectRowAtIndexPath:[[self fetchedResultsControllerForTableView:self.tableView] indexPathForObject:managedObject]  animated:YES];
}

- (void)deleteManagedObject:(NSManagedObject *)managedObject
{
    [_travel.managedObjectContext deleteObject:managedObject];
    [ReiseabrechnungAppDelegate saveContext:_travel.managedObjectContext];
}

- (BOOL)canDeleteManagedObject:(NSManagedObject *)managedObject
{
	return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)initFetchResultsController:(NSFetchRequest *)req {
    
    req.sortDescriptors = [NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:[_sortKeyArray objectAtIndex:_sortIndex] ascending:YES], [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES], nil];
    
    [NSFetchedResultsController deleteCacheWithName:@"Entries"];
    self.fetchedResultsController = [[[NSFetchedResultsController alloc] initWithFetchRequest:req managedObjectContext:self.travel.managedObjectContext sectionNameKeyPath:[_sortKeyArray objectAtIndex:_sortIndex] cacheName:@"Entries"] autorelease];    
}

- (void)sortTable:(int)sortIndex {
    _sortIndex = sortIndex;
    [self initFetchResultsController:self.fetchRequest];
    
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return nil;
}

#pragma mark - BadgeValue update 

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [super controllerDidChangeContent:controller];    
    [self.delegate didItemCountChange:[self.fetchedResultsController.fetchedObjects count]];
}

#pragma mark - View lifecycle

- (void)dealloc
{
    [_sortKeyArray release];
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

@end
