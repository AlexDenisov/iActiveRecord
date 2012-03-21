//
//  ARFactorySpecs.h
//  iActiveRecord
//
//  Created by Alex Denisov on 21.03.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import "Cedar-iOS/SpecHelper.h"
#define EXP_SHORTHAND
#import "Expecta.h"

#import "ARDatabaseManager.h"
#import "ARFactory.h"
#import "User.h"

SPEC_BEGIN(ARFactorySpecs)

beforeEach(^{
    [[ARDatabaseManager sharedInstance] clearDatabase];
});
afterEach(^{
    [[ARDatabaseManager sharedInstance] clearDatabase];
});

describe(@"Factory", ^{
    it(@"should return non zero records", ^{
        NSArray *records = [ARFactory buildFew:10
                                       records:[User class]];
        expect([records count]).Not.toEqual(0);
    });
    it(@"should return 10 records", ^{
        NSArray *records = [ARFactory buildFew:10
                                       records:[User class]];
        NSInteger count = [records count];
        NSInteger userCount = [User count];
        expect(count).toEqual(userCount);
    });
});

SPEC_END