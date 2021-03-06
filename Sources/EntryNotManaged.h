//
//  EntryNotManaged.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 01/07/2011.
//  Copyright 2011 Martin Maier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Participant.h"
#import "Travel.h"
#import "Currency.h"
#import "Type.h"

@interface EntryNotManaged : NSObject 

@property (nonatomic, retain) NSNumber * amount;
@property (nonatomic, retain) NSNumber * checked;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) Travel *travel;
@property (nonatomic, retain) Type *type;
@property (nonatomic, retain) Participant *payer;
@property (nonatomic, retain) NSMutableSet *receiverWeights;
@property (nonatomic, retain) Currency *currency;
@property (nonatomic, readonly) NSArray *sortedReceivers;

- (id)initWithEntry:(Entry *)entry;
- (BOOL)receiverWeightsDifferFromDefault;
- (NSArray *)sortedReceivers;
- (NSArray *)activeReceiverWeights;

@end
