//
//  City.h
//  Pindex
//
//  Created by Harrison Sweeney on 27/02/2014.
//  Copyright (c) 2014 Harrison Sweeney. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Category;
@class Country;

@interface City : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * state;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) Category *category;
@property (nonatomic, retain) Country *country;

@end
