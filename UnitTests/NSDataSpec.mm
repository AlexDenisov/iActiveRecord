#import "Cedar-iOS/SpecHelper.h"

using namespace Cedar::Matchers;

#import "ARDatabaseManager.h"
#import "User.h"


SPEC_BEGIN(NSDataSpecs)

beforeEach(^{
    [[ARDatabaseManager sharedInstance] clearDatabase];
});
afterEach(^{
    [[ARDatabaseManager sharedInstance] clearDatabase];
});

describe(@"NSData", ^{
    it(@"Should be saved successfully into database", ^{
        User *alex = [User newRecord];
        alex.name = @"Alex";
        NSData *data = [NSData dataWithBytes:"hello"
                                      length:5];
        alex.imageData = data;
        BOOL result = [alex save];
        result should BeTruthy();
    });
    it(@"Should be read successfully from database", ^{
        User *alex = [User newRecord];
        alex.name = @"Alex";
        NSString *octocat = [[NSBundle mainBundle] pathForResource:@"octocat"
                                                            ofType:@"png"];
        NSData *data = [NSData dataWithContentsOfFile:octocat];
        alex.imageData = data;
        BOOL result = [alex save];
        result should BeTruthy();
        User *fetchedUser = [[User allRecords] first];
        alex.imageData should equal(fetchedUser.imageData);
    });
});

SPEC_END
