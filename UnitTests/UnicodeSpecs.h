//
//  UnicodeSpecs.h
//  iActiveRecord
//
//  Created by Alex Denisov on 01.04.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import "Cedar-iOS/SpecHelper.h"
#define EXP_SHORTHAND
#import "Expecta.h"
#import "ARDatabaseManager.h"

#import "User.h"

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
        ARLazyFetcher *fetcher = [[User lazyFetcher] whereField:@"name"
                                                           like:@"%ксей%"];
        expect(fetcher.count).Not.toEqual(0);
    });
});

SPEC_END
