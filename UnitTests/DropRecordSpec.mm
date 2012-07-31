#import "Cedar-iOS/SpecHelper.h"

using namespace Cedar::Matchers;

#import "User.h"
#import "ARDatabaseManager.h"

SPEC_BEGIN(DropRecordSpecs)

beforeEach(^{
    [[ARDatabaseManager sharedInstance] clearDatabase];
});
afterEach(^{
    [[ARDatabaseManager sharedInstance] clearDatabase];
});

describe(@"Drop", ^{
    it(@"dropRecord should remove record from database", ^{
        NSString *username = @"Peter";
        User *peter = [User newRecord];
        peter.name = username;
        [peter save];
        NSInteger beforeCount = [User count];
        [peter dropRecord];
        NSInteger afterCount = [User count];
        beforeCount should_not equal(afterCount);
    });
    it(@"dropAllRecord should remove al records from database", ^{
        NSString *username = @"Peter";
        User *peter = [User newRecord];
        peter.name = username;
        [peter save];
        [User dropAllRecords];
        NSInteger count = [User count];
        count should equal(0);
    });
});

SPEC_END
