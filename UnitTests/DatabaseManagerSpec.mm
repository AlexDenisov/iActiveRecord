#import "Cedar-iOS/SpecHelper.h"

using namespace Cedar::Matchers;

#import "User.h"
#import "ARDatabaseManager.h"

SPEC_BEGIN(DatabaseManagerSpecs)

describe(@"ARDatabase", ^{
    it(@"Should clear all data", ^{
        User *user = [User newRecord];
        user.name = @"John";
        BOOL result = [user save];
        result should BeTruthy();
        [[ARDatabaseManager sharedInstance] clearDatabase];
        NSInteger count = [[User allRecords] count];
        count should equal(0);
    });
});

SPEC_END
