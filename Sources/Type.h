//
//  Type.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 21/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AppDefaults, Entry;

@interface Type : NSManagedObject

@property (nonatomic, retain) NSString * name_de;
@property (nonatomic, retain) NSNumber * builtIn;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * hidden;
@property (nonatomic, retain) NSSet *entries;
@property (nonatomic, retain) AppDefaults *defaults;
@end

@interface Type (CoreDataGeneratedAccessors)

- (void)addEntriesObject:(Entry *)value;
- (void)removeEntriesObject:(Entry *)value;
- (void)addEntries:(NSSet *)values;
- (void)removeEntries:(NSSet *)values;

@end
