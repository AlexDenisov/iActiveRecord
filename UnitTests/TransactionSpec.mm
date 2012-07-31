#import "Cedar-iOS/SpecHelper.h"

using namespace Cedar::Matchers;

#import "ARDatabaseManager.h"
#import "ActiveRecord.h"
#import "User.h"

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
