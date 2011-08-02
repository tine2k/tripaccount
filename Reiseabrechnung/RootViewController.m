//
//  RootViewController.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 28/06/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "RootViewController.h"
#import "TravelListViewController.h"
#import "UIFactory.h"
#import "TravelEditViewController.h"
#import "ShadowNavigationController.h"
#import "HelpView.h"
#import "InfoViewController.h"
#import "SettingsRootViewController.h"

@interface RootViewController ()
- (void)doneEditing;
- (void)changeToEditMode;
@end

@implementation RootViewController

@synthesize managedObjectContext=_managedObjectContext;
@synthesize tableViewController=_tableViewController;
@synthesize addButton=_addButton, editButton=_editButton, doneButton=_doneButton;

- (id) initInManagedObjectContext:(NSManagedObjectContext *) context {
    
    if (self = [super init]) {
        _managedObjectContext = context;
        
        self.tableViewController = [[[TravelListViewController alloc] initInManagedObjectContext:context withRootViewController:self] autorelease];
        self.tableViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - TOOLBAR_HEIGHT);
        self.tableViewController.view.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [self.view addSubview:self.tableViewController.view];
        
        self.title = @"Reiseabrechnungen";
        
        self.navigationItem.rightBarButtonItem = self.addButton;
        self.navigationItem.leftBarButtonItem = self.editButton;
    }
    return self;
}

- (UIBarButtonItem *) addButton {
    if (!_addButton) {
        _addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(openTravelEditViewController)];   
    }
    return [_addButton retain];    
}

- (UIBarButtonItem *) editButton {
    if (!_editButton) {
        _editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(changeToEditMode)]; 
    }
    return [_editButton retain];    
}

- (UIBarButtonItem *) doneButton {
    if (!_doneButton) {
        _doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneEditing)];
    }
    return [_doneButton retain];       
}

- (void)openTravelEditViewController {
    
    TravelEditViewController *detailViewController = [[TravelEditViewController alloc] initInManagedObjectContext:self.managedObjectContext];
    detailViewController.editDelegate = self;
    UINavigationController *navController = [[ShadowNavigationController alloc] initWithRootViewController:detailViewController];
    navController.delegate = detailViewController;
    
    [self.navigationController presentModalViewController:navController animated:YES];   
    [detailViewController release];
    [navController release];
}

- (void)travelDidSave:(Travel *)travel {
    [self doneEditing];
}

- (void)openInfoPopup {
    
    InfoViewController *infoViewController = [[InfoViewController alloc] init];
    
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:1.0];
	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight
						   forView:[self.navigationController.view superview]
							 cache:YES];
    
	[[self.navigationController.view superview] addSubview:infoViewController.view];
	[UIView commitAnimations];
}

- (void)openSettingsPopup {
    
    SettingsRootViewController *settingsViewController = [[SettingsRootViewController alloc] initInManagedObjectContext:self.managedObjectContext];
    UINavigationController *navController = [[ShadowNavigationController alloc] initWithRootViewController:settingsViewController];
    [self.navigationController presentModalViewController:navController animated:YES];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];

}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)changeToEditMode {
    [self.navigationItem setRightBarButtonItem:self.doneButton animated:YES];
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    [self.tableViewController.tableView setEditing:YES animated:YES];
}

- (void)doneEditing {
    [self.navigationItem setRightBarButtonItem:self.addButton animated:YES];
    [self.navigationItem setLeftBarButtonItem:self.editButton animated:YES];
    [self.tableViewController.tableView setEditing:NO animated:YES];
}

-(void)loadView {
    [super loadView];

    UIView *newView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] applicationFrame].size.width, [[UIScreen mainScreen] applicationFrame].size.height - NAVIGATIONBAR_HEIGHT)];
    newView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
    
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, newView.frame.size.height - TOOLBAR_HEIGHT, newView.frame.size.width, TOOLBAR_HEIGHT)];
    toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
    toolbar.barStyle = UIBarStyleBlack;
    toolbar.tintColor = [UIFactory defaultTintColor];
    
    UIBarButtonItem *infoButton = [[UIBarButtonItem alloc] initWithTitle:@"Info" style:UIBarButtonItemStyleBordered target:self action:@selector(openInfoPopup)];
    UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStyleBordered target:self action:@selector(openSettingsPopup)];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];

    toolbar.items = [NSArray arrayWithObjects:infoButton, flexibleSpace, settingsButton, nil];
    
    [infoButton release];
    [settingsButton release];
    [flexibleSpace release];
    
    [newView addSubview:toolbar];
    
    self.view = newView;
    
    [toolbar release];
    [newView release];
}

-(void)viewWillAppear:(BOOL)animated {
    
    if (!_helpView) {
        NSString *text = @"Use this button to add a new trip to start tracking your expenses.";
        _helpView = [[HelpView alloc] initWithFrame:CGRectMake(170, 2, 148, 90) text:text arrowPosition:ARROWPOSITION_TOP_RIGHT uniqueIdentifier:@"travel add button"];
        [self.view addSubview:_helpView];        
    }
}

- (void)dealloc {
    
    [super dealloc];
}

@end
