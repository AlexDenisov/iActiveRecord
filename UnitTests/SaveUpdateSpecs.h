//
//  SaveUpdateSpecs.h
//  iActiveRecord
//
//  Created by Alex Denisov on 17.06.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import "Cedar-iOS/SpecHelper.h"
#define EXP_SHORTHAND
#import "Expecta.h"
#import "ARDatabaseManager.h"
#import "Animal.h"

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
        expect(enot.save).toBeTruthy();
        recordId = enot.id;
        Animal *record = [[Animal allRecords] first];
        record.title = @"Enot";
        record.state = @"FuuBar";
        expect(record.id).toEqual(recordId);
        [record save];
        Animal *racoon = [[Animal allRecords] first];
        expect(racoon.id).toEqual(recordId);
        expect(racoon.title).toEqual(@"Enot");
        expect(racoon.state).toEqual(@"FuuBar");
    });
    it(@"should not validate properies that don't changed", ^{
        User *user = [[User newRecord] autorelease];
        user.name = @"Alex";
        expect(user.save).toBeTruthy();
        user.name = @"Alex";
        expect(user.save).toBeTruthy();
        expect(user.save).toBeTruthy();
    });
});

SPEC_END
