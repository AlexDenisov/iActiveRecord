//
//  RelationshipSpec.mm
//  iActiveRecord
//
//  Created by Alex Denisov on 01.08.12.
//  Copyright (c) 2012 okolodev.org. All rights reserved.
//

#import "SpecHelper.h"

#import "User.h"
#import "Group.h"
#import "Project.h"
#import "ARDatabaseManager.h"
#import "UserProjectRelationship.h"
#import "Animal.h"

using namespace Cedar::Matchers;

SPEC_BEGIN(RelationshipsSpecs)

beforeEach(^{
    prepareDatabaseManager();
    [[ARDatabaseManager sharedManager] clearDatabase];
});
afterEach(^{
    [[ARDatabaseManager sharedManager] clearDatabase];
});

describe(@"HasMany", ^{
    it(@"Group should have two users", ^{
        User *john = [User newRecord];
        john.name = @"John";
        BOOL result = [john save];
        result should BeTruthy();
        User *peter = [User newRecord];
        peter.name = @"Peter";
        result = [peter save];
        result should BeTruthy();
        Group *students = [Group newRecord];
        students.title = @"students";
        [students save] should BeTruthy();
        [students addUser:john];
        [students addUser:peter];
        NSInteger count = [[students users] count];
        count should equal(2);
    });
    it(@"Group should not add two equal users", ^{
        User *alex = [User newRecord];
        alex.name = @"Alex";
        [alex save] should BeTruthy();
        Project *project = [Project newRecord];
        project.name = @"students";
        project.save should BeTruthy();
        [project addUser:alex];
        [project addUser:alex];
        NSInteger count = project.users.count;
        count should equal(1);
    });
    it(@"Should remove relationship record", ^{
        [[ARDatabaseManager sharedManager] clearDatabase];
        User *alex = [User newRecord];
        alex.name = @"Alex";
        [alex save] should BeTruthy();
        Project *project = [Project newRecord];
        project.name = @"students";
        project.save should BeTruthy();
        [project addUser:alex];
        [project removeUser:alex];
        NSInteger count = [UserProjectRelationship count];
        count should equal(0);
    });
    it(@"When I remove user, user should not have group", ^{
        Group *group = [Group newRecord];
        group.title = @"PSV 1-16";
        [group save];
        User *user = [User newRecord];
        user.name = @"Alex";
        [user save];
        [user setGroup:group];
        [group removeUser:user];
        user.group should BeNil();
    });
});

describe(@"BelongsTo", ^{
    it(@"User should have one group", ^{
        User *john = [User newRecord];
        john.name = @"John";
        BOOL result = [john save];
        result should BeTruthy();
        User *peter = [User newRecord];
        peter.name = @"Peter";
        result = [peter save];
        result should BeTruthy();
        Group *students = [Group newRecord];
        students.title = @"students";
        [students save];
        [students addUser:john];
        [students addUser:peter];
        Group *group = [john group];
        [group title] should equal([students title]);
    });
    it(@"when i set belongsTo group, group should contain this user", ^{
        Group *group = [Group newRecord];
        group.title = @"PSV 1-16";
        [group save];
        User *user = [User newRecord];
        user.name = @"Alex";
        [user save];
        [user setGroup:group];
        User *foundedUser = [[[group users] fetchRecords] objectAtIndex:0];
        foundedUser.name should equal(user.name);
    });
    it(@"when i set belongsTo nil, i should remove relation", ^{
        Group *group = [Group newRecord];
        group.title = @"PSV 1-16";
        [group save];
        User *user = [User newRecord];
        user.name = @"Alex";
        [user save];
        [user setGroup:group];
        [user setGroup:nil];
        group.users.count should equal(0);
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
        projects.count should equal(2);
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
        users.count should equal(2);
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
        beforeCount should_not equal(afterCount);
    });
});

// Same test above testing lazy persistence.

describe(@"HasManyThroughQueue", ^{
    it(@"Queued User should have many projects ", ^{
        User *john = [User newRecord];
        john.name = @"John";
        User *peter = [User newRecord];
        peter.name = @"Peter";
        User *vova = [User newRecord];
        vova.name = @"Vladimir";

        Project *worldConquest = [Project newRecord];
        worldConquest.name = @"Conquest of the World";


        Project *makeTea = [Project newRecord];
        makeTea.name = @"Make tea";

        [worldConquest addUser:john];
        [worldConquest addUser:peter];
        [worldConquest save];

        [makeTea addUser:john];
        [makeTea addUser:vova];
        [makeTea save];

        NSArray *projects = [[john projects] fetchRecords];
        projects.count should equal(2);
    });
    it(@"Queued Project should have many users", ^{
        User *john = [User newRecord];
        john.name = @"John";

        User *peter = [User newRecord];
        peter.name = @"Peter";

        User *vova = [User newRecord];
        vova.name = @"Vladimir";

        Project *worldConquest = [Project newRecord];
        worldConquest.name = @"Conquest of the World";

        Project *makeTea = [Project newRecord];
        makeTea.name = @"Make tea";

        [worldConquest addUser:john];
        [worldConquest addUser:peter];
        [worldConquest save];

        [makeTea addUser:john];
        [makeTea addUser:vova];
        [makeTea save];

        NSArray *users = [[worldConquest users] fetchRecords];
        users.count should equal(2);
    });

    it(@"Project should create many pets through HasManyThrough relationship with existing child", ^{
        User *john = [User new: @{@"name": @"John"}];
        User *peter =  [User new: @{@"name": @"Peter"}];

        [john addAnimal:[Animal new: @{@"name":@"animal", @"state":@"good", @"title" : @"test title"}]];

        Project *worldConquest = [Project new: @{@"name": @"Conquest of the World"}];
        [worldConquest addUser:john];
        [worldConquest addUser:peter];
        [worldConquest save] should equal(TRUE);
        [[worldConquest.users fetchRecords] count] should equal(2);
        [Animal count] should equal(1);

        User *fetched_user = [[[[User lazyFetcher] where:@" name = %@ ", @"John", nil  ] fetchRecords] firstObject];
        Project *fetched_project = [[[[Project lazyFetcher] where:@" name = %@ ", @"Conquest of the World", nil  ] fetchRecords] firstObject];
        fetched_project.name should equal(@"Conquest of the World");
        fetched_user.name should equal(@"John");

        [fetched_user addAnimal:[Animal new: @{@"name":@"animal", @"state":@"okay", @"title" : @"test title2"}] ];
        [fetched_project addUser:fetched_user];  // Normally, Animal wouldn't be persisted because the fetched_user relation already exists
        [fetched_project save] should equal(TRUE);
        [fetched_user.pets count] should equal(2);
        [Animal count] should equal(2);
    });

    it(@"Project validation errors should propagate through HasManyThrough relationship", ^{
        User *john = [User new: @{@"name": @"John"}];
        User *peter =  [User new: @{@"name": @"Peter"}];
        Animal *animal = [Animal new: @{@"name":@"animal_error", @"state":@"good", @"title" : @"test title"}];

        [john addAnimal:animal];

        Project *worldConquest = [Project new: @{@"name": @"Conquest of the World"}];
        [worldConquest addUser:john];
        [worldConquest addUser:peter];
        [worldConquest save] should equal(NO);
        [worldConquest.errors count] should equal(1);
        [Animal count] should equal(0);

        // Correction of validation error should allow save.

        animal.name = @"animal";
        [worldConquest save] should equal(YES);
        [worldConquest.errors count] should equal(0);
        [Animal count] should equal(1);


    });

    it(@"when I remove Queued  user, group should not contain this user", ^{
        User *alex = [User newRecord];
        alex.name = @"Alex";

        Project *makeTea = [Project newRecord];
        makeTea.name = @"Make tea";
        [makeTea addUser:alex];
        [makeTea save];

        NSInteger beforeCount = [[alex projects] count];
        [alex removeProject:makeTea];
        NSInteger afterCount = [[alex projects] count];
        beforeCount should_not equal(afterCount);
    });
});



SPEC_END
