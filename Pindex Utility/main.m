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
        NSLog(@"Imported Cities: %@", cities);
        
        // Loop through the array and add objects to core data
        [cities enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            City *city = [NSEntityDescription insertNewObjectForEntityForName:@"Pin" inManagedObjectContext:context];
            city.name = [obj objectForKey:@"name"];
    
            double lat = [[obj objectForKey:@"latitude"] doubleValue];
            city.latitude = [NSNumber numberWithDouble:lat];
            
            double lon = [[obj objectForKey:@"longitude"] doubleValue];
            city.longitude = [NSNumber numberWithDouble:lon];
            
            NSError *error;
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
            NSLog(@"Name: %@", city.name);
            NSLog(@"Latitude: %@", city.latitude);
            NSLog(@"Longitude: %@", city.longitude);
        }
    }
    return 0;
}

