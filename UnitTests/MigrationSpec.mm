//
//  MigrationSpecs.mm
//  iActiveRecord
//
//  Created by Alex Denisov on 01.08.12.
//  Copyright (c) 2012 okolodev.org. All rights reserved.
//

#import "Cedar-iOS/SpecHelper.h"
#import "ARDatabaseManager.h"
#import "Animal.h"
#import "Entity.h"

using namespace Cedar::Matchers;

/*
 This spec run once, when record 'Entity' doesn't exists
 */

SPEC_BEGIN(MigrationsSpecs)

beforeEach(^{
    [[ARDatabaseManager sharedInstance] clearDatabase];
});
afterEach(^{
    [[ARDatabaseManager sharedInstance] clearDatabase];
});

describe(@"Add column", ^{
    it(@"animal should have new column", ^{
        Animal *animal = [Animal newRecord];
        animal.name = @"animal";
        animal.state = @"Full";
        BOOL result = [animal save];
        result should BeTruthy();
    });
});

describe(@"Create table", ^{
    it(@"new record should save successfully", ^{
        Entity *ent = [Entity newRecord];
        ent.property = @"LooLZ";
        [ent save] should BeTruthy();
    });
});

SPEC_END
