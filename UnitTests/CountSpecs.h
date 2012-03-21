//
//  CountSpecs.h
//  iActiveRecord
//
//  Created by Alex Denisov on 20.03.12.
//  Copyright (c) 2012 CoreInvader. All rights 

#import "Cedar-iOS/SpecHelper.h"
#define EXP_SHORTHAND
#import "Expecta.h"

#import "User.h"
#import "ARDatabaseManager.h"

SPEC_BEGIN(CountSpecs)

beforeEach(^{
    [[ARDatabaseManager sharedInstance] clearDatabase];
});
afterEach(^{
    [[ARDatabaseManager sharedInstance] clearDatabase];
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
        expect(count).toEqual(2);
    });
});

SPEC_END