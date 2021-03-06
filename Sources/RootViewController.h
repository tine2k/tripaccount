//
//  RootViewController.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 28/06/2011.
//  Copyright 2011 Martin Maier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Travel.h"
#import "Entry.h"
#import "Participant.h"
#import "CoreDataTableViewController.h"
#import "TravelEditViewController.h"
#import "InfoViewController.h"
#import "HelpView.h"

@interface RootViewController : UIViewController <TravelEditViewControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, retain, readonly) UIBarButtonItem *addButton;
@property (nonatomic, retain, readonly) UIBarButtonItem *editButton;
@property (nonatomic, retain, readonly) UIBarButtonItem *doneButton;

@property (nonatomic, retain) CoreDataTableViewController *tableViewController;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, retain) UIButton *infoButton;

@property (nonatomic, retain) InfoViewController *infoViewController;

@property (nonatomic) BOOL animationOngoing;

- (id)initInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

- (void)openTravelEditViewController;

@end
