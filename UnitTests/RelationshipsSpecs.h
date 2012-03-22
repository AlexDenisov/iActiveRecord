//
//  RelationshipsSpecs.h
//  iActiveRecord
//
//  Created by Alex Denisov on 15.02.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import "Cedar-iOS/SpecHelper.h"
#define EXP_SHORTHAND
#import "Expecta.h"

#import "User.h"
#import "Group.h"
#import "Project.h"
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
        [students addUser:john];
        [students addUser:peter];
        NSArray *users = [students users];
        NSInteger count = [users count];
        expect(count).toEqual(2);
    });
});

describe(@"BelongsTo", ^{
    it(@"User should have one group", ^{
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
        [students addUser:john];
        [students addUser:peter];
        Group *group = [john group];
        expect([group name]).toEqual([students name]);
    });
});

describe(@"HasManyThrough", ^{
    it(@"Users should have many projects", ^{
        User *john = [User newRecord];
        john.name = @"John";
        [john save];
        User *peter = [User newRecord];
        peter.name = @"Peter";
        [peter save];
        User *vova = [User newRecord];
        vova.name = @"Vladimir";
        [vova save];
        
        Project *worldConquest = [Project newRecord];
        worldConquest.name = @"Conquest of the World";
        [worldConquest save];
        
        Project *makeTea = [Project newRecord];
        makeTea.name = @"Make tea";
        [makeTea save];
        
        [worldConquest addUser:john];
        [worldConquest addUser:peter];
        
        [makeTea addUser:john];
        [makeTea addUser:vova];
        
        NSArray *projects = [john projects];
        NSArray *users = [worldConquest users];
        expect(projects.count).toEqual(2);
        expect(users.count).toEqual(2);
    });
});

SPEC_END
