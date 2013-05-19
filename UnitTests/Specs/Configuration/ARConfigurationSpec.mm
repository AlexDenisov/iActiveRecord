#import "SpecHelper.h"
#import "ARConfiguration.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(ARConfigurationSpec)

describe(@"ARConfiguration", ^{
    __block ARConfiguration *subject;

    beforeEach(^{
        subject = [ARConfiguration new];
    });
    
    describe(@"responds to", ^{
        
        it(@"databasePath", ^{
            subject should responds_to(@selector(databasePath));
        });
        
    });
    
    describe(@"databasePath", ^{
        
        it(@"nil by default", ^{
            subject.databasePath should be_nil;
        });
        
        it(@"ARCachesDatabasePath not nil", ^{
            ARCachesDatabasePath(nil) should_not be_nil;
        });
        
        it(@"ARDocumentsDatabasePath not nil", ^{
            ARDocumentsDatabasePath(nil) should_not be_nil;
        });
        
    });
    
});

SPEC_END
