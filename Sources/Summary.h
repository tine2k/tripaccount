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

@end

@interface Summary : NSObject

@property (nonatomic, retain) NSArray *results;
@property (nonatomic, retain) Currency *baseCurrency;
@property (nonatomic, retain, readonly) NSMutableDictionary *accounts;

+ (Summary *) createSummary:(Travel *) travel;

@end
