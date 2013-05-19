//
//  ARConfiguration.h
//  iActiveRecord
//
//  Created by Alex Denisov on 19.05.13.
//  Copyright (c) 2013 okolodev.org. All rights reserved.
//

#import <Foundation/Foundation.h>

#if defined __cplusplus
extern "C" {
#endif
    NSString *ARCachesDatabasePath(NSString *databaseName);
    NSString *ARDocumentsDatabasePath(NSString *databaseName);
#if defined __cplusplus
};
#endif

@interface ARConfiguration : NSObject

@property (nonatomic, copy) NSString *databasePath;
@property (nonatomic, getter = isMigrationsEnabled) BOOL migrationsEnabled;

@end
