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
    it(@"should return count one record", ^{
        NSString *username = @"Peter";
        User *peter = [User newRecord];
        peter.name = username;
        [peter save];
        
        NSInteger count = [User count];
        expect(count).toEqual(1);
    });
});

SPEC_END