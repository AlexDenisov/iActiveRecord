//
//  ARIndicesSpecs.h
//  iActiveRecord
//
//  Created by Alex Denisov on 02.07.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import "Cedar-iOS/SpecHelper.h"
#define EXP_SHORTHAND
#import "Expecta.h"
#import "ARDatabaseManager.h"

SPEC_BEGIN(IndicesPsecs)

beforeEach(^{
    [[ARDatabaseManager sharedInstance] clearDatabase];
});
afterEach(^{
    [[ARDatabaseManager sharedInstance] clearDatabase];
});

describe(@"User", ^{
    it(@"should have one index", ^{
        NSArray *indices = [[ARSchemaManager sharedInstance] indicesForRecord:[User class]];
        expect(indices.count).toEqual(1);
    });
});

SPEC_END
