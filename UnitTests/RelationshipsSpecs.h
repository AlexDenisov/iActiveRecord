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
        NSArray *users = [[students users] fetchRecords];
        NSInteger count = [users count];
        expect(count).toEqual(2);
    });
    it(@"When I remove user, user should not have group", ^{
        Group *group = [Group newRecord];
        group.name = @"PSV 1-16";
        [group save];
        User *user = [User newRecord];
        user.name = @"Alex";
        [user save];
        [user setGroup:group];
        [group removeUser:user];
        expect(user.group).toBeNil();
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
    it(@"when i set belongsTo group, group should contain this user", ^{
        Group *group = [Group newRecord];
        group.name = @"PSV 1-16";
        [group save];
        User *user = [User newRecord];
        user.name = @"Alex";
        [user save];
        [user setGroup:group];
        User *foundedUser = [[[group users] fetchRecords] first];
        expect(foundedUser.name).toEqual(user.name);        
    });
    it(@"when i set belongsTo nil, i should remove relation", ^{
        Group *group = [Group newRecord];
        group.name = @"PSV 1-16";
        [group save];
        User *user = [User newRecord];
        user.name = @"Alex";
        [user save];
        [user setGroup:group];
        [user setGroup:nil];
        expect(group.users.count).toEqual(0);
    });
});

describe(@"HasManyThrough", ^{
    it(@"User should have many projects", ^{
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
        
        NSArray *projects = [[john projects] fetchRecords];
        expect(projects.count).toEqual(2);
    });
    it(@"Project should have many users", ^{
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
        NSArray *users = [[worldConquest users] fetchRecords];
        expect(users.count).toEqual(2);
    });
    it(@"when I remove user, group should not contain this user", ^{
        User *alex = [User newRecord];
        alex.name = @"Alex";
        [alex save];
        Project *makeTea = [Project newRecord];
        makeTea.name = @"Make tea";
        [makeTea save];
        
        [makeTea addUser:alex];
        NSInteger beforeCount = [[alex projects] count];
        [alex removeProject:makeTea];
        NSInteger afterCount = [[alex projects] count];
        expect(beforeCount).Not.toEqual(afterCount);
    });
});

SPEC_END
