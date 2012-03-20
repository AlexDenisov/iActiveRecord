//
//  DropRecordSpecs.h
//  iActiveRecord
//
//  Created by Alex Denisov on 20.03.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import "Cedar-iOS/SpecHelper.h"
#define EXP_SHORTHAND
#import "Expecta.h"

#import "User.h"
#import "ARDatabaseManager.h"

SPEC_BEGIN(DropRecordSpecs)

beforeEach(^{
    [[ARDatabaseManager sharedInstance] clearDatabase];
});
afterEach(^{
    [[ARDatabaseManager sharedInstance] clearDatabase];
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
        expect(beforeCount).Not.toEqual(afterCount);
    });
    it(@"dropAllRecord should remove al records from database", ^{
        NSString *username = @"Peter";
        User *peter = [User newRecord];
        peter.name = username;
        [peter save];
        [User dropAllRecords];
        NSInteger count = [User count];
        expect(count).toEqual(0);
    });
});

SPEC_END