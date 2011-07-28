//
//  Summary.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 01/07/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Summary.h"
#import "Entry.h"
#import "Participant.h"

@implementation ParticipantKey

@synthesize payer, receiver;

- (id) initWithPayer:(Participant *)newPayer andReceiver:(Participant *)newReceiver {
    self = [super init];
    if (self) {
        self.payer = newPayer;
        self.receiver = newReceiver;
    }
    return self;
}
- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[ParticipantKey class]]) {
        return false;
    } else {
        ParticipantKey *compareObject = (ParticipantKey *) object;
        return [self.payer isEqual:compareObject.payer] && [self.receiver isEqual:compareObject.receiver];
    }
}
- (NSUInteger)hash {
    return self.payer.hash + self.receiver.hash;
}
- (id)copyWithZone:(NSZone *)zone {
    return [[ParticipantKey alloc] initWithPayer:self.payer andReceiver:self.receiver];
}

@end

// ------ SUMMARY IMPLEMENTATION ----------

@interface Summary ()
- (NSNumber *) getAccountOfPerson:(Participant *)person1 withPerson:(Participant *)person2;
- (void) setAccountOfPerson:(Participant *)person1 withPerson:(Participant *)person2 toBalance:(NSNumber *)balance;
@end

@implementation Summary

@synthesize results=_results, accounts=_accounts;

- (id) init {
    self = [super init];
    if (self) {
        _accounts = nil;
    }
    return self;
}

+ (Summary *) createSummary:(Travel *) travel {
    Summary *summary = [[[Summary alloc] init] autorelease];
      
    for (Entry *entry in travel.entries) {
        double divAmount = [entry.amount doubleValue] / [entry.receivers count];

        for (Participant *receiver in entry.receivers) {
            if (![receiver isEqual:entry.payer]) {
                NSNumber *balance = [summary getAccountOfPerson:entry.payer withPerson:receiver];
                [summary setAccountOfPerson:entry.payer withPerson:receiver toBalance:[NSNumber numberWithDouble:([balance doubleValue] + divAmount)]];
            }
        }
    }
    
    for (id key in [summary.accounts keyEnumerator]) {
        if ([[summary.accounts objectForKey:key] doubleValue] == 0) {
            [summary.accounts removeObjectForKey:key];
        }
    };
    
    return summary;
}

- (ParticipantKey *) createKey:(Participant *)person1 withPerson:(Participant *)person2 {
    ParticipantKey *key = [[[ParticipantKey alloc] initWithPayer:person1 andReceiver:person2] autorelease];
    if ([person1 hash] > [person2 hash]) {
        key = [[[ParticipantKey alloc] initWithPayer:person2 andReceiver:person1] autorelease];
    } 
    return key;
}

- (int) getMultiplierFromPerson:(Participant *)person1 withPerson:(Participant *)person2 {
    if ([person1 hash] > [person2 hash]) {
        return 1;
    } else {
        return -1;
    }
}

- (void) setAccountOfPerson:(Participant *)person1 withPerson:(Participant *)person2 toBalance:(NSNumber *)balance {
    ParticipantKey *key = [self createKey:(Participant *)person1 withPerson:(Participant *)person2];
    int multiplier = [self getMultiplierFromPerson:person1 withPerson:person2];
    [_accounts setObject:[NSNumber numberWithDouble:([balance doubleValue] * multiplier)] forKey:key];
}

- (NSNumber *) getAccountOfPerson:(Participant *)person1 withPerson:(Participant *)person2 {
    
    if (!_accounts) {
        _accounts = [[NSMutableDictionary alloc] init];
    }
    
    int multiplier = [self getMultiplierFromPerson:person1 withPerson:person2];
    ParticipantKey *key = [self createKey:(Participant *)person1 withPerson:(Participant *)person2];
 
    NSNumber *returnValue = [_accounts objectForKey:key];
    if (!returnValue) {
        returnValue = [[[NSNumber alloc] initWithInt:0] autorelease];
        [_accounts setObject:returnValue forKey:key];
    }
    return [NSNumber numberWithDouble:([returnValue doubleValue] * multiplier)];
    
}

@end
