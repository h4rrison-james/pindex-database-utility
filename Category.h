//
//  Category.h
//  Pindex Utility
//
//  Created by Harrison Sweeney on 4/03/2014.
//  Copyright (c) 2014 Harrison Sweeney. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class City;

@interface Category : NSManagedObject

@property (nonatomic, retain) id color;
@property (nonatomic, retain) NSString * icon;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *cities;
@end

@interface Category (CoreDataGeneratedAccessors)

- (void)addCitiesObject:(City *)value;
- (void)removeCitiesObject:(City *)value;
- (void)addCities:(NSSet *)values;
- (void)removeCities:(NSSet *)values;

@end
