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


describe(@"NewAndCreate", ^{
    it(@"should be successful with :new method ", ^{
        NSNumber *recordId = nil;
        Animal *enot = [Animal new: @{@"name":@"animal", @"title": @"Racoon"}];

        enot.save should BeTruthy();
        recordId = enot.id;
        Animal *racoon = [[Animal allRecords] objectAtIndex:0];

        racoon.id should equal(recordId);
        racoon.title should equal(@"Racoon");
        racoon.name should equal(@"animal");
    });



    it(@"should be successful with :create method ", ^{
        NSNumber *recordId = nil;
        Animal *enot = [Animal create: @{@"name":@"animal", @"title": @"Racoon"}] ;
        enot should_not be_nil;
        enot.id should_not be_nil;
        recordId = enot.id;

        Animal *racoon = [[Animal allRecords] objectAtIndex:0];

        racoon.id should equal(recordId);
        racoon.title should equal(@"Racoon");
        racoon.name should equal(@"animal");
    });

});

describe(@"Update", ^{
#warning separate this specs
    it(@"should be successful", ^{
        NSNumber *recordId = nil;
        Animal *enot = [Animal newRecord] ;
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
        User *user = [User newRecord];
        user.name = @"Alex";
        user.save should BeTruthy();
        user.name = @"Alex";
        user.save should BeTruthy();
        user.save should BeTruthy();
    });
    
    it(@"should save values with quotes", ^{
        User *user = [User newRecord];
        user.name = @"Al\"ex";
        user.save should be_truthy;
    });
    
    it(@"should update values with quotes", ^{
        User *user = [User newRecord];
        user.name = @"Peter";
        user.save should be_truthy;
        User *savedUser = [[User allRecords] lastObject];
        savedUser.name = @"Pet\"er";
        savedUser.save should be_truthy;
    });
    
    it(@"should save/load record with primitive types", ^{
        PrimitiveModel *model = [PrimitiveModel newRecord];

        char charValue = -42;
        unsigned char unsignedCharValue = 'q';

        short shortValue = -22;
        unsigned short unsignedShortValue = 23;

        NSInteger integerValue = 15;
        int intValue = 14;
        unsigned int unsignedIntValue = 223;

        long longValue = 14L;
        unsigned long unsignedLongValue = 42UL;

        long long longLongValue = 331LL;
        unsigned long long unsignedLongLongValue = 11124ULL;

        float floatValue = 17.43f;
        double doubleValue = 22.34;


        model.charProperty = charValue;
        model.unsignedCharProperty = unsignedCharValue;
        model.shortProperty = shortValue;
        model.unsignedShortProperty = unsignedShortValue;
        model.integerProperty = integerValue;
        model.intProperty = intValue;
        model.unsignedIntProperty = unsignedIntValue;
        model.longProperty = longValue;
        model.unsignedLongProperty = unsignedLongValue;
        model.longLongProperty = longLongValue;
        model.unsignedLongLongProperty = unsignedLongLongValue;
        model.floatProperty = floatValue;
        model.doubleProperty = doubleValue;

        [model save] should be_truthy;
        [model release];
        
        PrimitiveModel *loadedModel = [[PrimitiveModel allRecords] objectAtIndex:0];

        loadedModel.charProperty should equal(charValue);
        loadedModel.unsignedCharProperty should equal(unsignedCharValue);
        loadedModel.shortProperty should equal(shortValue);
        loadedModel.unsignedShortProperty should equal(unsignedShortValue);
        loadedModel.intProperty should equal(intValue);
        loadedModel.integerProperty should equal(integerValue);
        loadedModel.unsignedIntProperty should equal(unsignedIntValue);
        loadedModel.longProperty should equal(longValue);
        loadedModel.unsignedLongProperty should equal(unsignedLongValue);
        loadedModel.longLongProperty should equal(longLongValue);
        loadedModel.unsignedLongLongProperty should equal(unsignedLongLongValue);
        loadedModel.floatProperty should equal(floatValue);
        loadedModel.doubleProperty should equal(doubleValue);
    });
});

SPEC_END
