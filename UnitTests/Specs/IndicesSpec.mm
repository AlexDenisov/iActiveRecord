//
//  IndicesSpec.mm
//  iActiveRecord
//
//  Created by Alex Denisov on 01.08.12.
//  Copyright (c) 2012 okolodev.org. All rights reserved.
//

#import "Cedar-iOS/SpecHelper.h"
#import "ARDatabaseManager.h"
#import "ARSchemaManager.h"
#import "User.h"

using namespace Cedar::Matchers;

SPEC_BEGIN(IndicesSpecs)

beforeEach(^{
    [[ARDatabaseManager sharedInstance] clearDatabase];
});
afterEach(^{
    [[ARDatabaseManager sharedInstance] clearDatabase];
});

describe(@"User", ^{
    it(@"should have one index", ^{
        NSArray *indices = [[ARSchemaManager sharedInstance] indicesForRecord:[User class]];
        indices.count should equal(1);
    });
});

SPEC_END
