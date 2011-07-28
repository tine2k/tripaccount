//
//  EntrySortViewController.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 25/07/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Travel.h"
#import "EntryViewController.h"

@interface EntrySortViewController : UIViewController <EntryViewControllerDelegate> {
    Travel *_travel;
    EntryViewController *_detailViewController;
}

@property (nonatomic, retain) Travel *travel;
@property (nonatomic, retain) EntryViewController *detailViewController;

- (id)initWithTravel:(Travel *) travel;

@end
