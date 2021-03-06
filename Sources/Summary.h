//
//  Summary.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 01/07/2011.
//  Copyright 2011 Martin Maier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Travel.h"

@interface ParticipantKey : NSObject <NSCopying> {
    Participant *payer;
    Participant *receiver;
}
@property (nonatomic, retain) Participant *payer;
@property (nonatomic, retain) Participant *receiver;

- (id) initWithReceiver:(Participant *)newReceiver andPayer:(Participant *)newPayer;

@end

@interface Summary : NSObject

@property (nonatomic, retain) Currency *baseCurrency;
@property (nonatomic, retain) NSMutableDictionary *accounts;
@property (nonatomic, retain) NSNumberFormatter *formatter;

+ (Summary *)createSummary:(Travel *)travel;
+ (Summary *)createSummary:(Travel *)travel eliminateCircularDebts:(BOOL)performEliminateCircularDebts applyCashierOption:(BOOL)applyCashierOption;
+ (void)updateSummaryOfTravel:(Travel *)travel;
+ (void)updateSummaryOfTravel:(Travel *)travel eliminateCircularDebts:(BOOL)performEliminateCircularDebts applyCashierOption:(BOOL)applyCashierOption;
- (void)eliminateCircularDebts:(NSMutableDictionary *)arrayOfParticipantKeys;
- (void)applyCashierOption:(Participant *)cashier withParticipants:(NSSet *)participants;
- (Participant *)decideCashier:(Travel *)travel;

@end

