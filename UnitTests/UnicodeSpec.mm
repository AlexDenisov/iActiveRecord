//
//  UnicodeSpecs.mm
//  iActiveRecord
//
//  Created by Alex Denisov on 01.08.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import "Cedar-iOS/SpecHelper.h"
#import "ARDatabaseManager.h"
#import "User.h"

using namespace Cedar::Matchers;

SPEC_BEGIN(UnicodeSpecs)

beforeEach(^{
    [[ARDatabaseManager sharedInstance] clearDatabase];
});
afterEach(^{
    [[ARDatabaseManager sharedInstance] clearDatabase];
});

describe(@"Unicode search", ^{
    it(@"should find records", ^{
        User *alex = [User newRecord];
        alex.name = @"Алексей";
        [alex save];
        ARLazyFetcher *fetcher = [[User lazyFetcher] where:@"name LIKE '%%ксей%%'", nil];
        fetcher.count should_not equal(0);
    });
});

SPEC_END
