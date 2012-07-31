#import "Cedar-iOS/SpecHelper.h"

using namespace Cedar::Matchers;

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
        fetcher.count should_not equal(0);
    });
});

SPEC_END
