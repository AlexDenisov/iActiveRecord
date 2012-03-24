//
//  FinderSpecs.h
//  iActiveRecord
//
//  Created by Alex Denisov on 15.02.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import "Cedar-iOS/SpecHelper.h"
#define EXP_SHORTHAND
#import "Expecta.h"

#import "User.h"
#import "ARDatabaseManager.h"

SPEC_BEGIN(DatabaseManagerSpecs)

describe(@"ARDatabase", ^{
    it(@"Should clear all data", ^{
        User *user = [User newRecord];
        user.name = @"John";
        BOOL result = [user save];
        expect(result).toEqual(YES);
        [[ARDatabaseManager sharedInstance] clearDatabase];
        NSInteger count = [[User allRecords] count];
        expect(0).toEqual(count);
    });
});

SPEC_END