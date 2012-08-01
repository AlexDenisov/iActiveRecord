//
//  DatabaseManagerSpec.mm
//  iActiveRecord
//
//  Created by Alex Denisov on 01.08.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import "Cedar-iOS/SpecHelper.h"
#import "User.h"
#import "ARDatabaseManager.h"

using namespace Cedar::Matchers;

SPEC_BEGIN(DatabaseManagerSpecs)

describe(@"ARDatabase", ^{
    it(@"Should clear all data", ^{
        User *user = [User newRecord];
        user.name = @"John";
        BOOL result = [user save];
        result should BeTruthy();
        [[ARDatabaseManager sharedInstance] clearDatabase];
        NSInteger count = [[User allRecords] count];
        count should equal(0);
    });
});

SPEC_END
