//
//  TransactionSpecs.mm
//  iActiveRecord
//
//  Created by Alex Denisov on 01.08.12.
//  Copyright (c) 2012 okolodev.org. All rights reserved.
//

#import "SpecHelper.h"

#import "ARDatabaseManager.h"
#import "User.h"

using namespace Cedar::Matchers;

SPEC_BEGIN(TransactionSpecs)

beforeEach(^{
    prepareDatabaseManager();
    [[ARDatabaseManager sharedManager] clearDatabase];
});
afterEach(^{
    [[ARDatabaseManager sharedManager] clearDatabase];
});

describe(@"Transaction", ^{
    it(@"should save record", ^{
        NSInteger beforeCount = [User count];
        [ActiveRecord transaction:^{
            User *alex = [User newRecord];
            alex.name = @"Alex";
            [alex save];
        }];
        NSInteger afterCount = [User count];
        beforeCount should_not equal(afterCount);
    });
    it(@"should not save record", ^{
        NSInteger beforeCount = [User count];
        [ActiveRecord transaction:^{
            User *alex = [User newRecord];
            alex.name = @"Alex";
            [alex save];
            ar_rollback
        }];
        NSInteger afterCount = [User count];
        beforeCount should equal(afterCount);
    });
});

SPEC_END
