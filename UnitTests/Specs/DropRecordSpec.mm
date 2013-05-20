//
//  DropRecordSpec.mm
//  iActiveRecord
//
//  Created by Alex Denisov on 01.08.12.
//  Copyright (c) 2012 okolodev.org. All rights reserved.
//

#import "SpecHelper.h"
#import "User.h"
#import "ARDatabaseManager.h"

using namespace Cedar::Matchers;

SPEC_BEGIN(DropRecordSpecs)

beforeEach(^{
    prepareDatabaseManager();
    [[ARDatabaseManager sharedManager] clearDatabase];
});
afterEach(^{
    [[ARDatabaseManager sharedManager] clearDatabase];
});

describe(@"Drop", ^{
    it(@"dropRecord should remove record from database", ^{
        NSString *username = @"Peter";
        User *peter = [User newRecord];
        peter.name = username;
        [peter save];
        NSInteger beforeCount = [User count];
        [peter dropRecord];
        NSInteger afterCount = [User count];
        beforeCount should_not equal(afterCount);
    });
    it(@"dropAllRecord should remove al records from database", ^{
        NSString *username = @"Peter";
        User *peter = [User newRecord];
        peter.name = username;
        [peter save];
        [User dropAllRecords];
        NSInteger count = [User count];
        count should equal(0);
    });
});

SPEC_END
