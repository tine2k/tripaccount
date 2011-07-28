//
//  ParticipantSelectViewController.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 01/07/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GenericSelectViewController.h"
#import "CountryCell.h"
#import "UIFactory.h"

@interface GenericSelectViewController () 

@property (retain, readonly) NSMutableArray *selectedObjects;
- (void)done;
- (void)updateSegmentedControl;
@end

@implementation GenericSelectViewController

@synthesize multiSelectionAllowed=_multiSelectionAllowed, cellClass=_cellClass;

- (id)initInManagedObjectContext:(NSManagedObjectContext *)context 
              withMultiSelection:(BOOL)multiSelection 
                withFetchRequest:(NSFetchRequest *)fetchRequest
             withSelectedObjects:(NSArray *)newSelectedObjects
                          target:(id)target 
                          action:(SEL)selector; {
    return [self initInManagedObjectContext:context withMultiSelection:multiSelection withFetchRequest:fetchRequest withSectionKey:nil withSelectedObjects:newSelectedObjects target:target action:selector];
                              
}

- (id)initInManagedObjectContext:(NSManagedObjectContext *)context 
              withMultiSelection:(BOOL)multiSelection 
                withFetchRequest:(NSFetchRequest *)fetchRequest
                  withSectionKey:(NSString *)sectionKey
             withSelectedObjects:(NSArray *)newSelectedObjects
                          target:(id)target 
                          action:(SEL)selector; {
    
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        _selector = selector;
        _target = target;
        _multiSelectionAllowed = multiSelection;
        
        [UIFactory initializeTableViewController:self.tableView];
        
        for (id obj in newSelectedObjects) {
            [self.selectedObjects addObject:obj];
        }        

        self.titleKey = @"name";
        
        if (multiSelection) {
            self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)] autorelease];
            [self.navigationController.view setNeedsDisplay];
            [self.navigationItem setHidesBackButton:YES animated:NO];
        }
        
        if (fetchRequest.predicate) {
            [NSFetchedResultsController deleteCacheWithName:[[fetchRequest entity] name]];
        }
        self.fetchedResultsController = [[[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:sectionKey cacheName:(fetchRequest.predicate)?nil:[[fetchRequest entity] name]] autorelease];
        self.fetchedResultsController.delegate = self;
        
        [self viewWillAppear:true];

    }
    return self;
}

- (void)managedObjectSelected:(NSManagedObject *)managedObject {
    
    if (!self.multiSelectionAllowed) {
        [self.selectedObjects removeAllObjects];
        [self.selectedObjects addObject:managedObject];
        [self done];
    } else {
        if (![self.selectedObjects containsObject:managedObject]) {
            [self.selectedObjects addObject:managedObject];
        } else {
            [self.selectedObjects removeObject:managedObject];
        }
    }
    [self updateSegmentedControl];    
    
    UITableView *tableViewOrSearchTableView = self.tableView;
    if (self.searchDisplayController.active) {
        tableViewOrSearchTableView = self.searchDisplayController.searchResultsTableView;
    }
    
    NSIndexPath *cellIndexPath = [[self fetchedResultsControllerForTableView:tableViewOrSearchTableView] indexPathForObject:managedObject];
    [tableViewOrSearchTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:cellIndexPath] withRowAnimation:UITableViewRowAnimationNone];
    [tableViewOrSearchTableView selectRowAtIndexPath:cellIndexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    [tableViewOrSearchTableView deselectRowAtIndexPath:cellIndexPath animated:YES];
}

- (UITableViewCell *)newUIViewCell {
    if (self.cellClass) {
        return [self.cellClass alloc];
    } else {
        return [super newUIViewCell];
    }
}

- (void) updateSegmentedControl {
    if (_segControl) {
        if ([self.selectedObjects count] == [self.fetchedResultsController.fetchedObjects count]) {
            _segControl.selectedSegmentIndex = ALL_BUTTON_INDEX;
        } else if ([self.selectedObjects count] == 0) {
            _segControl.selectedSegmentIndex = NONE_BUTTON_INDEX;
        } else {
            _segControl.selectedSegmentIndex = UISegmentedControlNoSegment;
        }
    }           
}

- (NSMutableArray *)selectedObjects {
    if (!_selectedObjects) {
        _selectedObjects = [[[NSMutableArray alloc] init] retain];
    }
    return _selectedObjects;
}

- (void)done {
    if ([_target respondsToSelector:_selector]) {
        if (!self.multiSelectionAllowed) {
            [_target performSelector:_selector withObject:[self.selectedObjects lastObject]];
        } else {
            [_target performSelector:_selector withObject:self.selectedObjects];
        }
    }    
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)selectAll:(id)sender {
    
    NSMutableArray *indexPathArray = [[NSMutableArray alloc] init];
    for (id obj in self.fetchedResultsController.fetchedObjects) {
        if (![self.selectedObjects containsObject:obj]) {
            [self.selectedObjects addObject:obj];
            [indexPathArray addObject:[[self fetchedResultsControllerForTableView:self.tableView] indexPathForObject:obj]];
        }
    }
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
    
    for (id indexPath in indexPathArray) {
        [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];        
    }
    
    [indexPathArray release];
}

- (void)selectNone:(id)sender {
    NSMutableArray *indexPathArray = [[NSMutableArray alloc] init];
    for (id obj in self.fetchedResultsController.fetchedObjects) {
        if ([self.selectedObjects containsObject:obj]) {
            [self.selectedObjects removeObject:obj];
            [indexPathArray addObject:[[self fetchedResultsControllerForTableView:self.tableView] indexPathForObject:obj]];
        }
    }
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
    
    for (id indexPath in indexPathArray) {
        [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];        
    }    

    [indexPathArray release];
}

- (UITableViewCellAccessoryType)accessoryTypeForManagedObject:(NSManagedObject *)managedObject {
    if ([self.selectedObjects containsObject:managedObject]) {
        return UITableViewCellAccessoryCheckmark;
    } else {
        return UITableViewCellAccessoryNone;
    }
}

- (void)dealloc
{
    [_segControl release];
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)selectParticipants:(UISegmentedControl *) sender {
    if ([sender selectedSegmentIndex] == ALL_BUTTON_INDEX) {
        [self selectAll:sender];
    } else if ([sender selectedSegmentIndex] == NONE_BUTTON_INDEX) {
        [self selectNone:sender];
    }
}

-(void)loadView {
    [super loadView];
}

- (UIView *)createTableHeaderSubView {
    
    if (self.multiSelectionAllowed) {
        NSString *selectAllButton = @"All";
        NSString *selectNoneButton = @"None";            
        
        _segControl = [[[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:selectAllButton, selectNoneButton, nil]] retain];
        _segControl.frame = CGRectMake(10, 10, self.tableView.bounds.size.width - 20, 40);
        _segControl.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [_segControl addTarget:self action:@selector(selectParticipants:) forControlEvents:UIControlEventValueChanged];
        _segControl.selectedSegmentIndex = UISegmentedControlNoSegment;
        
        _segControlView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 60)] retain];
        _segControlView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [_segControlView addSubview:_segControl];
        
        return _segControlView;
    } else {
        return nil;
    }
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    NSMutableArray* array = [NSMutableArray arrayWithArray:[super sectionIndexTitlesForTableView:tableView]];
    if (self.searchKey) {
        [array insertObject:UITableViewIndexSearch atIndex:0];
    }
    return array;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    if (self.searchKey) {
        if (index == 0) {
            [tableView setContentOffset:CGPointZero animated:NO];
            return NSNotFound;
        } else {
            return [[self fetchedResultsControllerForTableView:tableView] sectionForSectionIndexTitle:title atIndex:index-1];
        }
    } else {
        return [super tableView:tableView sectionForSectionIndexTitle:title atIndex:index];
    }
}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    if (self.multiSelectionAllowed && section == 0) {
//        return 60;
//    } else {
//        return [UIFactory getDefaultSectionHeaderCellHeight]; ;
//    }
//}

#pragma mark - View lifecycle                   

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateSegmentedControl];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
