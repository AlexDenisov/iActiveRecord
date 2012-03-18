//
//  FinderSpecs.h
//  iActiveRecord
//
//  Created by Alex Denisov on 15.02.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import "Cedar-iOS/SpecHelper.h"
#define EXP_SHORTHAND
#import "Expecta.h"

#import "User.h"
#import "ARDatabaseManager.h"

SPEC_BEGIN(DatabaseManagerSpecs)

describe(@"ARDatabase", ^{
    it(@"Should clear all data", ^{
        User *user = [User newRecord];
        user.name = @"John";
        BOOL result = [user save];
        expect(result).toEqual(YES);
        [[ARDatabaseManager sharedInstance] clearDatabase];
        NSInteger count = [[User allRecords] count];
        expect(0).toEqual(count);
    });
});

describe(@"whereKeyHasValue", ^{
    it(@"should find user by key/value", ^{
        NSString *username = @"Peter";
        User *peter = [User newRecord];
        peter.name = username;
        [peter save];
        User *founded = [[[ARDatabaseManager sharedInstance] allRecordsWithName:@"User"
                                                                       whereKey:@"name" 
                                                                       hasValue:username] objectAtIndex:0];
        BOOL equality = [peter.name isEqualToString:founded.name];
        expect(equality).toEqual(YES);
    });
});

describe(@"whereKeyIn", ^{
    it(@"should find user by key in array", ^{
        NSString *username = @"Peter";
        User *peter = [User newRecord];
        peter.name = username;
        [peter save];
        NSArray *names = [NSArray arrayWithObjects:
                          @"Vavilen", 
                          username, 
                          @"Tyler", nil];
        User *founded = [[[ARDatabaseManager sharedInstance] allRecordsWithName:@"User"
                                                                       whereKey:@"name"
                                                                             in:names] objectAtIndex:0];
        
        BOOL equality = [peter.name isEqualToString:founded.name];
        expect(equality).toEqual(YES);
    });
});

SPEC_END