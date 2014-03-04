//
//  City.h
//  Pindex Utility
//
//  Created by Harrison Sweeney on 4/03/2014.
//  Copyright (c) 2014 Harrison Sweeney. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Category, Country;

@interface City : NSManagedObject

@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * state;
@property (nonatomic, retain) NSNumber * population;
@property (nonatomic, retain) NSNumber * scalerank;
@property (nonatomic, retain) Category *category;
@property (nonatomic, retain) Country *country;

@end
