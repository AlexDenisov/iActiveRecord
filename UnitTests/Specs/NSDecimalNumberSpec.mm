#import "Cedar-iOS/SpecHelper.h"
#import "DecimalRecord.h"
#import "ARDatabaseManager.h"

using namespace Cedar::Matchers;

SPEC_BEGIN(NSDecimalNumberSpec)

beforeEach(^{
    [[ARDatabaseManager sharedInstance] clearDatabase];
});
afterEach(^{
    [[ARDatabaseManager sharedInstance] clearDatabase];
});

describe(@"NSDecimalNumberSpec", ^{
    it(@"should return the same NSDecimalNumber value after saving", ^{
        DecimalRecord *record = [DecimalRecord newRecord];
        NSDecimalNumber *testDecimal = [NSDecimalNumber decimalNumberWithMantissa:1123563 exponent:-3 isNegative:NO];
        record.decimal = testDecimal;
        [record save];
        ARLazyFetcher *fetcher = [DecimalRecord lazyFetcher];
        [fetcher where:@"id = %@", record.id, nil];
        record = [[fetcher fetchRecords] objectAtIndex:0];
        record.decimal should equal(testDecimal);
    });
});

SPEC_END
