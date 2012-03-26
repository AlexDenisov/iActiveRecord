//
//  DependencySpecs.h
//  iActiveRecord
//
//  Created by Alex Denisov on 26.03.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import "Cedar-iOS/SpecHelper.h"
#define EXP_SHORTHAND
#import "Expecta.h"
#import "ARDatabaseManager.h"

#import "User.h"
#import "Project.h"
#import "Group.h"

SPEC_BEGIN(DependencySpecs)

beforeEach(^{
    [[ARDatabaseManager sharedInstance] clearDatabase];
});
afterEach(^{
    [[ARDatabaseManager sharedInstance] clearDatabase];
});

describe(@"Destroy", ^{
    it(@"HasMany", ^{
        User *john = [User newRecord];
        john.name = @"John";
        [john save];
        
        User *alex = [User newRecord];
        alex.name = @"Alex";
        [alex save];
        
        Group *students = [Group newRecord];
        students.name = @"Students";
        [students save];
        
        [students addUser:john];
        [students addUser:alex];
        
        [students dropRecord];
        [alex release];
        [john release];
        [students release];
        
        expect([User count]).toEqual(0);
    });
    it(@"BelongsTo", ^{
        User *john = [User newRecord];
        john.name = @"John";
        [john save];
        User *peter = [User newRecord];
        peter.name = @"Peter";
        [peter save];
        
        Group *students = [Group newRecord];
        students.name = @"Students";
        [students save];
        
        [students addUser:john];
        [students addUser:peter];
        
        [john dropRecord];
        expect([Group count]).toEqual(0);
        expect([User count]).toEqual(0);
    });
});

SPEC_END