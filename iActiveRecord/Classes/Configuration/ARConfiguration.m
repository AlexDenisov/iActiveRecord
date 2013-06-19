//
//  ARConfiguration.m
//  iActiveRecord
//
//  Created by Alex Denisov on 19.05.13.
//  Copyright (c) 2013 okolodev.org. All rights reserved.
//

#import "ARConfiguration.h"

static NSString *defaultDatabaseName() {
    return @"iactiverecord.sqlite";
}

static NSString *DatabasePathWithSearchMask(NSSearchPathDirectory searchPath, NSString *databaseName) {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(searchPath, NSUserDomainMask, YES);
    NSString *directory = [paths count] ? [paths objectAtIndex:0] : nil;
    NSString *dbName = databaseName ?: defaultDatabaseName();
    return [directory stringByAppendingPathComponent:dbName];
}

NSString *ARCachesDatabasePath(NSString *databaseName) {
    return DatabasePathWithSearchMask(NSCachesDirectory, databaseName);
}

NSString *ARDocumentsDatabasePath(NSString *databaseName) {
    return DatabasePathWithSearchMask(NSDocumentDirectory, databaseName);
}

@implementation ARConfiguration

- (instancetype)init {
    self = [super init];
    if (self) {
        self.migrationsEnabled = YES;
        self.databasePath = ARDocumentsDatabasePath(nil);
    }
    return self;
}

@end
