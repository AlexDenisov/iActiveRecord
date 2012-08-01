//
//  ValidationSpec.mm
//  iActiveRecord
//
//  Created by Alex Denisov on 01.08.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import "Cedar-iOS/SpecHelper.h"
#import "User.h"
#import "ARDatabaseManager.h"
#import "Animal.h"

using namespace Cedar::Matchers;

SPEC_BEGIN(ValidationSpecs)

beforeEach(^{
    [[ARDatabaseManager sharedInstance] clearDatabase];
});
afterEach(^{
    [[ARDatabaseManager sharedInstance] clearDatabase];
});

describe(@"Presence", ^{
    it(@"Should not save User with empty name", ^{
        User *user = [User newRecord];
        user.name = @"";
        BOOL result = [user save];
        result should_not BeTruthy();
//        result should_not BeTruthy();
    });
    it(@"Should save User with some name", ^{
        User *user = [User newRecord];
        user.name = @"John";
        BOOL result = [user save];
        result should BeTruthy();
//        result should BeTruthy();
    });
});

describe(@"Uniqueness", ^{
    it(@"Should not save User with same name", ^{
        User *john = [User newRecord];
        john.name = @"John";
        BOOL result = [john save];

        result should BeTruthy();
        User *john2 = [User newRecord];
        john2.name = @"John";
        result = [john2 save];
        result should_not BeTruthy();
    });
    it(@"Should save User with some name", ^{
        User *john = [User newRecord];
        john.name = @"John";
        BOOL result = [john save];
        result should BeTruthy();
        User *peter = [User newRecord];
        peter.name = @"Peter";
        result = [peter save];
        result should BeTruthy();
    });
    it(@"Should update fetched User", ^{
        User *john = [User newRecord];
        john.name = @"John";
        BOOL result = [john save];
        result should BeTruthy();
        User *user = [[[[User lazyFetcher] limit:1] fetchRecords] first];
        user.updatedAt = [NSDate dateWithTimeIntervalSinceNow:0];
        user.save should BeTruthy();
    });
});

describe(@"Custom validator", ^{
    it(@"Animal name should be valid", ^{
        Animal *animal = [Animal newRecord];
        animal.name = @"animal";
        [animal save] should BeTruthy();
    });
    it(@"Animal name should not be valid", ^{
        Animal *animal = [Animal newRecord];
        animal.name = @"bear";
        [animal save] should_not BeTruthy();
    });
});

SPEC_END
