//
//  LazyFetcherSpec.mm
//  iActiveRecord
//
//  Created by Alex Denisov on 01.08.12.
//  Copyright (c) 2012 okolodev.org. All rights reserved.
//

#import "SpecHelper.h"

#import "User.h"
#import "ARDatabaseManager.h"
#import "ARFactory.h"
#import "DifferentTableName.h"

using namespace Cedar::Matchers;

#define DAY (24*60*60)
#define MONTH (30*DAY)

CDR_EXT
Tsuga<ARLazyFetcher>::run(^{
    
    beforeEach(^{
        prepareDatabaseManager();
        [[ARDatabaseManager sharedManager] clearDatabase];
        [ARFactory buildFew:10 recordsNamed:@"User"];
    });

    afterEach(^{
        [[ARDatabaseManager sharedManager] clearDatabase];
    });

    describe(@"LazyFetcher", ^{
        it(@"without parameters should return all records ", ^{
            NSArray *records = [[User lazyFetcher] fetchRecords];
            [records count] should equal(10);
        });    
        
            
        describe(@"Limit/Offset", ^{
            it(@"LIMIT should return limited count of records", ^{
                NSInteger limit = 5;
                NSArray *records = [[[User lazyFetcher] limit:limit] fetchRecords];
                [records count] should equal(limit);
            });
            it(@"OFFSET should return records from third record", ^{
                NSInteger offset = 3;
                NSArray *records = [[[User lazyFetcher] offset:offset] fetchRecords];
                User *first = [records objectAtIndex:0];
                first.id.integerValue should equal(offset + 1);
            });
            it(@"LIMIT/OFFSET should return 5 records starts from 3-d", ^{
                NSInteger limit = 5;
                NSInteger offset = 3;
                NSArray *records = [[[[User lazyFetcher] limit:limit] offset:offset] fetchRecords];
                User *first = [records objectAtIndex:0];
                first.id.integerValue should equal(offset + 1);
                records.count should equal(limit);
            });

        });
        
        describe(@"Order by", ^{
            it(@"ASC should sort records in ascending order", ^{
                NSArray *records = [[[User lazyFetcher] orderBy:@"id"
                                                      ascending:YES] fetchRecords];
                int idx = 1;
                BOOL sortCorrect = YES;
                for(User *user in records){
                    if(user.id.integerValue != idx++){
                        sortCorrect = NO;
                    }
                }
                sortCorrect should equal(YES);
            });
            it(@"ASC with LIMIT should sort limited records in ascending order", ^{
                NSInteger limit = 5;
                NSArray *records = [[[[User lazyFetcher] orderBy:@"id"
                                                       ascending:YES] limit:limit] fetchRecords];
                int idx = 1;
                BOOL sortCorrect = YES;
                for(User *user in records){
                    if(user.id.integerValue != idx++){
                        sortCorrect = NO;
                    }
                }
                sortCorrect should equal(YES);
            });
            it(@"ASC with LIMIT/OFFSET should sort limited records in ascending order", ^{
                NSInteger limit = 5;
                NSInteger offset = 4;
                NSArray *records = [[[[[User lazyFetcher] orderBy:@"id"
                                                       ascending:YES] offset:offset] limit:limit] fetchRecords];
                int idx = offset + 1;
                BOOL sortCorrect = YES;
                for(User *user in records){
                    if(user.id.integerValue != idx++){
                        sortCorrect = NO;
                    }
                }
                sortCorrect should equal(YES);
            });
            it(@"DESC should sort records in descending order", ^{
                NSArray *records = [[[User lazyFetcher] orderBy:@"id"
                                                      ascending:NO] fetchRecords];
                int idx = 10;
                BOOL sortCorrect = YES;
                for(User *user in records){
                    if(user.id.integerValue != idx--){
                        sortCorrect = NO;
                    }
                }
                sortCorrect should equal(YES);
            });
        });
        
        describe(@"New Where syntax", ^{
           describe(@"where between", ^{
                it(@"should fetch only records between two dates", ^{
                    [ActiveRecord clearDatabase];
                    NSDate *startDate = [NSDate dateWithTimeIntervalSinceNow:-MONTH];
                    NSDate *endDate = [NSDate dateWithTimeIntervalSinceNow:DAY];
                    User *john = [User newRecord];
                    john.name = @"John";
                    john.createdAt = [NSDate dateWithTimeIntervalSinceNow:-MONTH * 2];
                    [john save] should equal(YES);
                    User *alex = [User newRecord];
                    alex.name = @"Alex";
                    alex.createdAt = [NSDate dateWithTimeIntervalSinceNow:-DAY];
                    [alex save] should equal(YES);
                    ARLazyFetcher *fetcher = [User lazyFetcher];
                    [fetcher where:
                     @"createdAt BETWEEN %@ AND %@", 
                     startDate, 
                     endDate, nil];
                    NSArray *users = [fetcher fetchRecords];
                    users.count should equal(1);
                });
            }); 
            describe(@"Simple where conditions", ^{
                it(@"whereField equalToValue should find record", ^{
                    NSString *username = @"john";
                    User *john = [User newRecord];
                    john.name = username;
                    [john save];
                    ARLazyFetcher *fetcher = [User lazyFetcher];
                    [fetcher where:@"name == %@", username, nil];
                    User *founded = [[fetcher fetchRecords] objectAtIndex:0];
                    founded.name should equal(username);
                });
                it(@"whereField notEqualToValue should not find record", ^{
                    NSString *username = @"john";
                    User *john = [User newRecord];
                    john.name = username;
                    [john save];
                    ARLazyFetcher *fetcher = [User lazyFetcher];
                    [fetcher where:@"name <> %@", username, nil];
                    User *founded = [[fetcher fetchRecords] objectAtIndex:0];
                    founded.name should_not equal(username);
                });
                it(@"WhereField in should find record", ^{
                    NSString *username = @"john";
                    NSArray *names = [NSArray arrayWithObjects:@"alex", username, @"peter", nil];
                    User *john = [User newRecord];
                    john.name = username;
                    [john save];
                    ARLazyFetcher *fetcher = [User lazyFetcher];
                    [fetcher where:@"name in %@", names, nil];
                    User *founded = [[fetcher fetchRecords] objectAtIndex:0];
                    founded.name should equal(username);
                });
                it(@"WhereField notIn should not find record", ^{
                    NSString *username = @"john";
                    NSArray *names = [NSArray arrayWithObjects:@"alex", username, @"peter", nil];
                    User *john = [User newRecord];
                    john.name = username;
                    [john save];
                    ARLazyFetcher *fetcher = [User lazyFetcher];
                    [fetcher where:@"name not in %@", names, nil];
                    User *founded = [[fetcher fetchRecords] objectAtIndex:0];
                    founded.name should_not equal(username);
                });
                it(@"WhereField LIKE should find record", ^{
                    NSString *username = @"john";
                    User *john = [User newRecord];
                    john.name = username;
                    [john save];
                    ARLazyFetcher *fetcher = [User lazyFetcher];
                    [fetcher where:@"name like %@", @"%jo%", nil];
                    User *founded = [[fetcher fetchRecords] objectAtIndex:0];
                    founded.name should equal(username);
                });
            });
            describe(@"Complex where conditions", ^{
                it(@"Two conditions should return actual values", ^{
                    NSArray *ids = [NSArray arrayWithObjects:
                                    [NSNumber numberWithInt:1],
                                    [NSNumber numberWithInt:15], 
                                    nil];
                    NSString *username = @"john";
                    User *john = [User newRecord];
                    john.name = username;
                    [john save];
                    ARLazyFetcher *fetcher = [User lazyFetcher];
                    [fetcher where:
                     @"'user'.'name' = %@ or 'user'.'id' in %@", 
                     username, ids, nil];
                    [fetcher orderBy:@"id"];
                    NSArray *records = [fetcher fetchRecords];
                    BOOL idStatementSuccess = NO;
                    BOOL nameStatementSuccess = NO;
                    for(User *user in records){
                        if([ids containsObject:user.id]){
                            idStatementSuccess = YES;
                        }
                        if([user.name isEqualToString:username]){
                            nameStatementSuccess = YES;
                        }
                    }
                    idStatementSuccess should equal(YES);
                    nameStatementSuccess should equal(YES); 
                });
            });
        });
        
        describe(@"select", ^{
            it(@"only should return only listed fields", ^{
                ARLazyFetcher *fetcher = [[User lazyFetcher] only:@"name", @"id", nil];
                User *john = [User newRecord];
                john.name = @"john";
                john.groupId = [NSNumber numberWithInt:145];
                [john save];
                User *user = [[fetcher fetchRecords] lastObject];
                user.groupId should BeNil();
            });
            it(@"except should return only not listed fields", ^{
                ARLazyFetcher *fetcher = [[User lazyFetcher] except:@"name", nil];
                User *john = [User newRecord];
                john.name = @"john";
                john.groupId = [NSNumber numberWithInt:145];
                [john save];
                User *user = [[fetcher fetchRecords] lastObject];
                user.name should BeNil();
            });
        });
        
        describe(@"joined records", ^{
            it(@"should be able to fetch joined records with different table names", ^{
                User *john = [User newRecord];
                john.name = @"john";
                john.save should BeTruthy();
                DifferentTableName* dtn = [DifferentTableName newRecord];
                dtn.title = @"testTitle";
                dtn.user = john;
                [dtn save] should BeTruthy();
                
                //try to fetch the joined records
                NSArray* results = [[[User lazyFetcher] join: DifferentTableName.class
                                                      useJoin: ARJoinInner onField: @"id" andField: @"userId"] fetchJoinedRecords];

                results should_not BeNil();
                results.count should equal(1);
                [[results objectAtIndex: 0] objectForKey: @"User"] should_not BeNil();
                [[[results objectAtIndex: 0] objectForKey: @"User"] isKindOfClass: User.class ] should equal(YES);
                
                User* user = [[results objectAtIndex: 0] objectForKey: @"User"];
                [john.id isEqualToNumber: user.id] should equal(YES);
                [[results objectAtIndex: 0] objectForKey: @"DifferentTableName"] should_not BeNil();
                [[[results objectAtIndex: 0] objectForKey: @"DifferentTableName"] isKindOfClass: DifferentTableName.class] should equal(YES);
                
                
            });
        });
    });
    
});
