//
//  ValidationsSpecs.h
//  iActiveRecord
//
//  Created by mls on 15.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Cedar-iOS/SpecHelper.h"
#define EXP_SHORTHAND
#import "Expecta.h"

#import "User.h"
#import "ARDatabaseManager.h"

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
        expect(result).Not.toEqual(YES);
    });
    it(@"Should save User with some name", ^{
        User *user = [User newRecord];
        user.name = @"John";
        BOOL result = [user save];
        expect(result).toEqual(YES);
    });
});

describe(@"Uniqueness", ^{
    it(@"Should not save User with same name", ^{
        User *john = [User newRecord];
        john.name = @"John";
        BOOL result = [john save];
        expect(result).toEqual(YES);
        User *john2 = [User newRecord];
        john2.name = @"John";
        result = [john2 save];
        expect(result).Not.toEqual(YES);
    });
    it(@"Should save User with some name", ^{
        User *john = [User newRecord];
        john.name = @"John";
        BOOL result = [john save];
        expect(result).toEqual(YES);
        User *peter = [User newRecord];
        peter.name = @"Peter";
        result = [peter save];
        expect(result).toEqual(YES);
    });
});

SPEC_END
