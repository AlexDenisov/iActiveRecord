//
//  NSDateSpec.mm
//  iActiveRecord
//
//  Created by James Whitfield on 03.29.14.
//  Copyright (c) 2012 okolodev.org. All rights reserved.
//

#import "SpecHelper.h"

#import "ARDatabaseManager.h"
#import "User.h"

using namespace Cedar::Matchers;

CDR_EXT
Tsuga<NSDate>::run(^{

    beforeEach(^{
        prepareDatabaseManager();
        [[ARDatabaseManager sharedManager] clearDatabase];
    });

    afterEach(^{
        [[ARDatabaseManager sharedManager] clearDatabase];
    });

    describe(@"NSDate", ^{
        it(@"Should be saved successfully and return the same date", ^{
            User *alex = [User newRecord];
            alex.name = @"Alex";
            alex.birthDate = [NSDate dateWithTimeIntervalSince1970:0];
            BOOL result = [alex save];

            User *fetchedUser = [[User allRecords] objectAtIndex:0];
            fetchedUser should_not be_nil;
            alex.birthDate should equal(fetchedUser.birthDate);
        });

    });

});
