//
//  FinderSpecs.h
//  iActiveRecord
//
//  Created by Alex Denisov on 18.03.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import "Cedar-iOS/SpecHelper.h"
#define EXP_SHORTHAND
#import "Expecta.h"

#import "User.h"
#import "ARDatabaseManager.h"

SPEC_BEGIN(FinderSpecs)

beforeEach(^{
    [[ARDatabaseManager sharedInstance] clearDatabase];
});
afterEach(^{
    [[ARDatabaseManager sharedInstance] clearDatabase];
});

describe(@"findBy", ^{
    it(@"user should be founded by id", ^{
        NSString *username = @"Peter";
        User *peter = [User newRecord];
        peter.name = username;
        [peter save];
        User *founded = [User findById:peter.id];
        BOOL equality = [peter.name isEqualToString:founded.name];
        expect(equality).toEqual(YES);
    });
    it(@"user should be founded by name", ^{
        NSString *username = @"Peter";
        User *peter = [User newRecord];
        peter.name = username;
        [peter save];
        User *founded = [[User performSelector:@selector(findByName:) withObject:username] objectAtIndex:0];
        BOOL equality = [peter.name isEqualToString:founded.name];
        expect(equality).toEqual(YES);
    });
});

SPEC_END