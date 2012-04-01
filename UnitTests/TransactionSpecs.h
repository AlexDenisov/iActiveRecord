//
//  TransactionSpecs.h
//  iActiveRecord
//
//  Created by Alex Denisov on 01.04.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import "Cedar-iOS/SpecHelper.h"
#define EXP_SHORTHAND
#import "Expecta.h"
#import "ARDatabaseManager.h"

SPEC_BEGIN(TransactionSpecs)

beforeEach(^{
    [[ARDatabaseManager sharedInstance] clearDatabase];
});
afterEach(^{
    [[ARDatabaseManager sharedInstance] clearDatabase];
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
        expect(beforeCount).Not.toEqual(afterCount);
    });
    it(@"should not save record", ^{
        NSInteger beforeCount = [User count];
        [ActiveRecord transaction:^{
            User *alex = [User newRecord];
            alex.name = @"Alex";
            [alex save];
            rollback
        }];
        NSInteger afterCount = [User count];
        expect(beforeCount).toEqual(afterCount);
    });
});

SPEC_END
