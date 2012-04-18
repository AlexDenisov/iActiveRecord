//
//  NSDataSpecs.h
//  iActiveRecord
//
//  Created by Alex Denisov on 18.04.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import "Cedar-iOS/SpecHelper.h"
#define EXP_SHORTHAND
#import "Expecta.h"
#import "ARDatabaseManager.h"
#import "User.h"


SPEC_BEGIN(NSDataSpecs)

beforeEach(^{
    [[ARDatabaseManager sharedInstance] clearDatabase];
});
afterEach(^{
    [[ARDatabaseManager sharedInstance] clearDatabase];
});

describe(@"NSData", ^{
    it(@"Should be saved successfully into database", ^{
        User *alex = [User newRecord];
        alex.name = @"Alex";
        NSData *data = [NSData dataWithBytes:"hello"
                                      length:5];
        alex.imageData = data;
        BOOL result = [alex save];
        expect(result).toEqual(YES);
    });
    it(@"Should be read successfully from database", ^{
        User *alex = [User newRecord];
        alex.name = @"Alex";
        NSString *octocat = [[NSBundle mainBundle] pathForResource:@"octocat"
                                                            ofType:@"png"];
        NSData *data = [NSData dataWithContentsOfFile:octocat];
        alex.imageData = data;
        BOOL result = [alex save];
        expect(result).toEqual(YES);
        
        User *fetchedUser = [[User allRecords] first];
        expect(alex.imageData).toEqual(fetchedUser.imageData);
    });
});

SPEC_END