//
//  ARSchemaManagerSpecs.h
//  iActiveRecord
//
//  Created by Alex Denisov on 17.06.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import "Cedar-iOS/SpecHelper.h"
#define EXP_SHORTHAND
#import "Expecta.h"
#import "ARDatabaseManager.h"
#import "User.h"

SPEC_BEGIN(ARSchemaManagerSpecs)

beforeEach(^{
    [[ARDatabaseManager sharedInstance] clearDatabase];
});
afterEach(^{
    [[ARDatabaseManager sharedInstance] clearDatabase];
});

describe(@"SchemaManager", ^{
    it(@"should return nil on undefined column", ^{
        [[ARSchemaManager sharedInstance] registerSchemeForRecord:[User class]];
        ARColumn *column = [User columnNamed:@"FUUU"];
        expect(column).toBeNil();
    });
});

SPEC_END
