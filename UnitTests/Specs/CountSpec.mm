//
//  CountSpec.mm
//  iActiveRecord
//
//  Created by Alex Denisov on 01.08.12.
//  Copyright (c) 2012 okolodev.org. All rights reserver.

#import "SpecHelper.h"

#import "ARDatabaseManager.h"
#import "User.h"
#import "ARDatabaseManager.h"

using namespace Cedar::Matchers;

SPEC_BEGIN(CountSpecs)

beforeEach(^{
    prepareDatabaseManager();
    [[ARDatabaseManager sharedManager] clearDatabase];
});
afterEach(^{
    [[ARDatabaseManager sharedManager] clearDatabase];
});

describe(@"Count", ^{
    it(@"should return 2", ^{
        NSString *username = @"Peter";
        User *peter = [User newRecord];
        peter.name = username;
        [peter save];
        User *john = [User newRecord];
        john.name = @"john";
        [john save];
        NSInteger count = [User count];
        count should equal(2);
    });
});

SPEC_END
