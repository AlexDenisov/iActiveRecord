//
//  DatabaseManagerSpec.mm
//  iActiveRecord
//
//  Created by Alex Denisov on 01.08.12.
//  Copyright (c) 2012 okolodev.org. All rights reserved.
//

#import "SpecHelper.h"

#import "User.h"
#import "ARDatabaseManager.h"
#import "DifferentTableName.h"

#import "ARConfiguration.h"

using namespace Cedar::Matchers;

SPEC_BEGIN(DatabaseManagerSpecs)

beforeEach(^{
    prepareDatabaseManager();
});

describe(@"ARDatabase", ^{
    it(@"Should clear all data", ^{
        User *user = [User newRecord];
        user.name = @"John";
        BOOL result = [user save];
        result should BeTruthy();
        [[ARDatabaseManager sharedManager] clearDatabase];
        NSInteger count = [[User allRecords] count];
        count should equal(0);
    });
    
    it(@"should use recordName instead of class name", ^{
        ARDatabaseManager *databaseManager = [ARDatabaseManager sharedManager];
        databaseManager.tables should contain([DifferentTableName recordName]);
    });
    
    it(@"save records with different table name", ^{
        NSString *title = @"Does ot works?";
        DifferentTableName *model = [DifferentTableName newRecord];
        model.title = title;
        [model save] should be_truthy;
        
        DifferentTableName *loadedModel = [[DifferentTableName allRecords] objectAtIndex:0];
        loadedModel.title should equal(title);
    });
});

SPEC_END
