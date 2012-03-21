//
//  ARArraySpecs.h
//  iActiveRecord
//
//  Created by Alex Denisov on 21.03.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import "Cedar-iOS/SpecHelper.h"
#define EXP_SHORTHAND
#import "Expecta.h"

#import "User.h"
#import "ARDatabaseManager.h"
#import "ARFactory.h"

SPEC_BEGIN(ARLazyFetcherSpecs)

beforeEach(^{
    [[ARDatabaseManager sharedInstance] clearDatabase];
});
afterEach(^{
    [[ARDatabaseManager sharedInstance] clearDatabase];
});

describe(@"ActiveRecord", ^{
    it(@"fetchRecords without parameters should return all records ", ^{
        [ARFactory buildFew:10 recordsNamed:@"User"];
        NSArray *records = [[User lazyFetcher] fetchRecords];
        expect([records count]).toEqual(10);
    });
});

SPEC_END