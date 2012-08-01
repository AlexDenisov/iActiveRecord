//
//  SchemaManagerSpec.mm
//  iActiveRecord
//
//  Created by Alex Denisov on 01.08.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import "Cedar-iOS/SpecHelper.h"
#import "ARDatabaseManager.h"
#import "ActiveRecord_Private.h"
#import "User.h"
#import "ARSchemaManager.h"
#import "ARColumn.h"

using namespace Cedar::Matchers;

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
        column should BeNil();
    });
});

SPEC_END
