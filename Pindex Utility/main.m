//
//  main.m
//  Pindex Utility
//
//  Created by Harrison Sweeney on 27/02/2014.
//  Copyright (c) 2014 Harrison Sweeney. All rights reserved.
//

#import "City.h"
#import "Category.h"
#import "Country.h"
#import <AppKit/AppKit.h>

static NSManagedObjectModel *managedObjectModel()
{
    static NSManagedObjectModel *model = nil;
    if (model != nil) {
        return model;
    }
    
    NSString *path = @"Pindex Model";
    path = [path stringByDeletingPathExtension];
    NSURL *modelURL = [NSURL fileURLWithPath:[path stringByAppendingPathExtension:@"momd"]];
    model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    return model;
}

static NSManagedObjectContext *managedObjectContext()
{
    static NSManagedObjectContext *context = nil;
    if (context != nil) {
        return context;
    }

    @autoreleasepool {
        context = [[NSManagedObjectContext alloc] init];
        
        NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel()];
        [context setPersistentStoreCoordinator:coordinator];
        
        NSString *STORE_TYPE = NSSQLiteStoreType;
        
        NSString *path = [[NSProcessInfo processInfo] arguments][0];
        path = [path stringByDeletingPathExtension];
        NSURL *url = [NSURL fileURLWithPath:[path stringByAppendingPathExtension:@"sqlite"]];
        
        NSError *error;
        NSPersistentStore *newStore = [coordinator addPersistentStoreWithType:STORE_TYPE configuration:nil URL:url options:nil error:&error];
        
        if (newStore == nil) {
            NSLog(@"Store Configuration Failure %@", ([error localizedDescription] != nil) ? [error localizedDescription] : @"Unknown Error");
        }
    }
    return context;
}

int main(int argc, const char * argv[])
{

    @autoreleasepool {
        // Create the managed object context
        NSManagedObjectContext *context = managedObjectContext();
        
        // Custom code here...
        // Save the managed object context
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Error while saving %@", ([error localizedDescription] != nil) ? [error localizedDescription] : @"Unknown Error");
            exit(1);
        }
        
        NSError* err = nil;
        NSString* dataPath = [[NSBundle mainBundle] pathForResource:@"cities" ofType:@"json"];
        NSArray* cities = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:dataPath]
                                                         options:kNilOptions
                                                           error:&err];
        
        // Add default category
        Category *category = [NSEntityDescription insertNewObjectForEntityForName:@"Category" inManagedObjectContext:context];
        category.name = @"Default";
        category.icon = @"circle";
        
        // Loop through the array and add objects to core data
        [cities enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            City *city = [NSEntityDescription insertNewObjectForEntityForName:@"Pin" inManagedObjectContext:context];
            city.name = [obj objectForKey:@"name"];
            city.state = [obj objectForKey:@"adm1name"];
    
            double lat = [[obj objectForKey:@"latitude"] doubleValue];
            city.latitude = [NSNumber numberWithDouble:lat];
            
            double lon = [[obj objectForKey:@"longitude"] doubleValue];
            city.longitude = [NSNumber numberWithDouble:lon];
            
            double pop = [[obj objectForKey:@"pop"] doubleValue];
            city.population = [NSNumber numberWithDouble:pop];
            
            NSInteger rank = [[obj objectForKey:@"scalerank"] integerValue];
            city.scalerank = [NSNumber numberWithInteger:rank];
            
            // Set up the fetch request to check if country exists
            NSString *countryName = [obj objectForKey:@"adm0name"];
            NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Country"];
            [request setReturnsObjectsAsFaults:NO];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name contains[cd] %@", countryName];
            request.predicate = predicate;
            NSError *error;
            
            // Create new country if it hasn't been already
            NSArray *result = [context executeFetchRequest:request error:&error];
            if ([result count] == 0) {
                Country *country = [NSEntityDescription insertNewObjectForEntityForName:@"Country" inManagedObjectContext:context];
                country.name = [obj objectForKey:@"adm0name"];
                country.iso = [obj objectForKey:@"iso"];
                
                NSString *path = [[NSBundle mainBundle] pathForResource:country.iso ofType:@"png"];
                NSData *data = [NSData dataWithContentsOfFile:path];
                country.flag = data;
                
                city.country = country;
            }
            else {
                city.country = (Country *)[result firstObject];
            }
            
            if (![context save:&error]) {
                NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
            }
        }];
        
        // Test listing all the pins from core data
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Pin" inManagedObjectContext:context];
        [fetchRequest setEntity:entity];
        
        NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
        for (City *city in fetchedObjects) {
            Country *country = city.country;
            NSLog(@"Name: %@, %@", city.name, country.name);
            //NSLog(@"Latitude: %@", city.latitude);
            //NSLog(@"Longitude: %@", city.longitude);
        }
        
        // Test listing all countries from core data
        fetchRequest = [[NSFetchRequest alloc] init];
        entity = [NSEntityDescription entityForName:@"Country" inManagedObjectContext:context];
        [fetchRequest setEntity:entity];
        
        fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
        for (Country *country in fetchedObjects) {
            //NSLog(@"Name: %@", country.name);
        }
    }
    return 0;
}

