//
//  Travel.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 01/07/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Currency, Entry, Participant;

@interface Travel : NSManagedObject {
@private
}
@property (nonatomic, retain) NSDate * created;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet* entries;
@property (nonatomic, retain) NSSet* participants;
@property (nonatomic, retain) Currency * currency;

@end
