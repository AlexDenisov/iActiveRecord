#import "Cedar-iOS/SpecHelper.h"

using namespace Cedar::Matchers;

#import "ARDatabaseManager.h"
#import "User.h"
#import "Project.h"
#import "Group.h"
#import "Issue.h"

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
        students.title = @"Students";
        [students save];
        
        [students addUser:john];
        [students addUser:alex];
        
        [students dropRecord];
        [alex release];
        [john release];
        [students release];
        [User count] should equal(0);
    });
    it(@"BelongsTo", ^{
        User *john = [User newRecord];
        john.name = @"John";
        [john save];
        User *peter = [User newRecord];
        peter.name = @"Peter";
        [peter save];
        
        Group *students = [Group newRecord];
        students.title = @"Students";
        [students save];
        
        [students addUser:john];
        [students addUser:peter];
        [john dropRecord];
        [Group count] should equal(0);
        [User count] should equal(0);
    });
    it(@"HasManyThrough", ^{
        User *john = [User newRecord];
        john.name = @"John";
        [john save];
        
        Project *makeTea = [Project newRecord];
        makeTea.name = @"Make tea";
        [makeTea save];
        
        [makeTea addUser:john];
        [john dropRecord];
        [User count] should equal(0);
        [Project count] should equal(0);
    });
});

describe(@"Destroy/Nulify", ^{
    describe(@"HasMany - destroy, BelongsTo - nullify", ^{
        it(@"when i drop project it should drop all issues", ^{
            Issue *issue = [Issue newRecord];
            issue.title = @"new issue";
            [issue save];
            Project *project = [Project newRecord];
            project.name = @"Make tea";
            [project save];
            [project addIssue:issue];
            Issue *emptyIssue = [Issue newRecord];
            emptyIssue.title = @"empty";
            [emptyIssue save];
            [project dropRecord];
            [Issue count] should equal(1);
        });
        it(@"when i drop issue it should not drop project issues", ^{
            Issue *issue = [Issue newRecord];
            issue.title = @"new issue";
            [issue save];
            Project *project = [Project newRecord];
            project.name = @"Make tea";
            [project save];
            [project addIssue:issue];
            Issue *emptyIssue = [Issue newRecord];
            emptyIssue.title = @"empty";
            [emptyIssue save];
            
            NSInteger count = [Project count];
            
            [issue dropRecord];
            [Project count] should equal(count);
        });
    });
});


describe(@"Nulify", ^{
    it(@"when i drop project it should not drop group", ^{
        Group *students = [Group newRecord];
        students.title = @"Students";
        [students save];
        
        Project *project = [Project newRecord];
        project.name = @"Make tea";
        [project save];
        [project addGroup:students];
        
        [project dropRecord];
        [Group count] should equal(1);
    });
});


SPEC_END
