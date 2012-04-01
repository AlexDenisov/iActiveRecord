//
//  MigrationsSpecs.h
//  iActiveRecord
//
//  Created by Alex Denisov on 01.04.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import "Cedar-iOS/SpecHelper.h"
#define EXP_SHORTHAND
#import "Expecta.h"
#import "ARDatabaseManager.h"
#import "Animal.h"
#import "Entity.h"

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
        expect(result).toEqual(YES);
    });
});

describe(@"Create table", ^{
    it(@"new record should save successfully", ^{
        Entity *ent = [Entity newRecord];
        ent.property = @"LooLZ";
        expect([ent save]).toEqual(YES);
    });
});

SPEC_END

