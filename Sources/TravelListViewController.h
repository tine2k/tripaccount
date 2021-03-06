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

@interface TravelListViewController : CoreDataTableViewController <UIAlertViewDelegate> {
    
    NSManagedObjectContext *_managedObjectContext;
}

@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) UIViewController <TravelEditViewControllerDelegate> *rootViewController;

@property (nonatomic, retain) UIAlertView *openTripAlert;
@property (nonatomic, retain) UIAlertView *refreshRatesAlert;

- (id)initInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext withRootViewController:(UIViewController *)rootViewController;

@end
