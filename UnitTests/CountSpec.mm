#import "Cedar-iOS/SpecHelper.h"
using namespace Cedar::Matchers;

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
    it(@"should return 2", ^{
        NSString *username = @"Peter";
        User *peter = [User newRecord];
        peter.name = username;
        [peter save];
        User *john = [User newRecord];
        john.name = @"john";
        [john save];
        NSInteger count = [User count];
        count should equal(2);
    });
});

SPEC_END
