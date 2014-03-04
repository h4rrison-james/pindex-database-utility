//
//  Country.h
//  Pindex Utility
//
//  Created by Harrison Sweeney on 4/03/2014.
//  Copyright (c) 2014 Harrison Sweeney. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class City;

@interface Country : NSManagedObject

@property (nonatomic, retain) id flag;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * iso;
@property (nonatomic, retain) NSSet *pins;
@end

@interface Country (CoreDataGeneratedAccessors)

- (void)addPinsObject:(City *)value;
- (void)removePinsObject:(City *)value;
- (void)addPins:(NSSet *)values;
- (void)removePins:(NSSet *)values;

@end
