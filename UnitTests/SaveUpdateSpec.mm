//
//  SaveUpdateSpec.h
//  iActiveRecord
//
//  Created by Alex Denisov on 01.08.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import "Cedar-iOS/SpecHelper.h"
#import "ARDatabaseManager.h"
#import "Animal.h"
#import "User.h"

using namespace Cedar::Matchers;

SPEC_BEGIN(SaveUpdateSpecs)

beforeEach(^{
    [[ARDatabaseManager sharedInstance] clearDatabase];
});
afterEach(^{
    [[ARDatabaseManager sharedInstance] clearDatabase];
});

describe(@"Update", ^{
    it(@"should be successful", ^{
        NSNumber *recordId = nil;
        Animal *enot = [[Animal newRecord] autorelease];
        enot.name = @"animal";
        enot.title = @"Racoon";
        enot.save should BeTruthy();
        recordId = enot.id;
        Animal *record = [[Animal allRecords] first];
        record.title = @"Enot";
        record.state = @"FuuBar";
        record.id should equal(recordId);
        [record save];
        Animal *racoon = [[Animal allRecords] first];
        racoon.id should equal(recordId);
        racoon.title should equal(@"Enot");
        racoon.state should equal(@"FuuBar");
    });
    it(@"should not validate properies that don't changed", ^{
        User *user = [[User newRecord] autorelease];
        user.name = @"Alex";
        user.save should BeTruthy();
        user.name = @"Alex";
        user.save should BeTruthy();
        user.save should BeTruthy();
    });
});

SPEC_END
