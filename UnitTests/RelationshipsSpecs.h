//
//  RelationshipsSpecs.h
//  iActiveRecord
//
//  Created by mls on 15.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Cedar-iOS/SpecHelper.h"
#define EXP_SHORTHAND
#import "Expecta.h"

#import "User.h"
#import "Group.h"
#import "ARDatabaseManager.h"

SPEC_BEGIN(RelationshipsSpecs)

beforeEach(^{
    [[ARDatabaseManager sharedInstance] clearDatabase];
});
afterEach(^{
    [[ARDatabaseManager sharedInstance] clearDatabase];
});

describe(@"HasMany", ^{
    it(@"Group should have two users", ^{
        User *john = [User newRecord];
        john.name = @"John";
        BOOL result = [john save];
        expect(result).toEqual(YES);
        User *peter = [User newRecord];
        peter.name = @"Peter";
        result = [peter save];
        expect(result).toEqual(YES);
        
        Group *students = [Group newRecord];
        students.name = @"students";
        [students save];
        [students performSelector:@selector(addUser:) withObject:john];
        [students performSelector:@selector(addUser:) withObject:peter];
        NSArray *users = [students performSelector:@selector(users)];
        NSInteger count = [users count];
        expect(count).toEqual(2);
    });
});

SPEC_END
