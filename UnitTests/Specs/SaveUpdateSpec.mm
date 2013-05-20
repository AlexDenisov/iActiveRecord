//
//  SaveUpdateSpec.h
//  iActiveRecord
//
//  Created by Alex Denisov on 01.08.12.
//  Copyright (c) 2012 okolodev.org. All rights reserved.
//

#import "SpecHelper.h"

#import "ARDatabaseManager.h"
#import "Animal.h"
#import "User.h"
#import "PrimitiveModel.h"

using namespace Cedar::Matchers;

SPEC_BEGIN(SaveUpdateSpecs)

beforeEach(^{
    prepareDatabaseManager();
    [[ARDatabaseManager sharedManager] clearDatabase];
});
afterEach(^{
    [[ARDatabaseManager sharedManager] clearDatabase];
});

describe(@"Update", ^{
#warning separate this specs
    it(@"should be successful", ^{
        NSNumber *recordId = nil;
        Animal *enot = [[Animal newRecord] autorelease];
        enot.name = @"animal";
        enot.title = @"Racoon";
        enot.save should BeTruthy();
        recordId = enot.id;
        Animal *record = [[Animal allRecords] objectAtIndex:0];
        record.title = @"Enot";
        record.state = @"FuuBar";
        record.id should equal(recordId);
        [record save];
        Animal *racoon = [[Animal allRecords] objectAtIndex:0];
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
    
    it(@"should save/load record with primitive types", ^{
        PrimitiveModel *model = [PrimitiveModel newRecord];
        NSInteger integerValue = 15;
        int intValue = 14;
        float floatValue = 17.43f;
        double doubleValue = 22.34;
        model.integerProperty = integerValue;
        model.intProperty = intValue;
        model.floatProperty = floatValue;
        model.doubleProperty = doubleValue;
        [model save] should be_truthy;
        [model release];
        
        PrimitiveModel *loadedModel = [[PrimitiveModel allRecords] objectAtIndex:0];
        loadedModel.intProperty should equal(intValue);
        loadedModel.integerProperty should equal(integerValue);
        loadedModel.floatProperty should equal(floatValue);
        loadedModel.doubleProperty should equal(doubleValue);
    });
});

SPEC_END
