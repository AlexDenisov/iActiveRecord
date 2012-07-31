#import "Cedar-iOS/SpecHelper.h"

using namespace Cedar::Matchers;

#import "User.h"
#import "ARDatabaseManager.h"
#import "ARFactory.h"
#import "ARWhereStatement.h"

#define DAY (24*60*60)
#define MONTH (30*DAY)

SPEC_BEGIN(ARLazyFetcherSpecs)

beforeEach(^{
    [[ARDatabaseManager sharedInstance] clearDatabase];
    [ARFactory buildFew:10 recordsNamed:@"User"];
});

afterEach(^{
    [[ARDatabaseManager sharedInstance] clearDatabase];
});

describe(@"LazyFetcher", ^{
    it(@"without parameters should return all records ", ^{
        NSArray *records = [[User lazyFetcher] fetchRecords];
        records.count should equal(10);
//        expect([records count]).toEqual(10);
    });
    
    
    describe(@"Limit/Offset", ^{
        it(@"LIMIT should return limited count of records", ^{
            NSInteger limit = 5;
            NSArray *records = [[[User lazyFetcher] limit:limit] fetchRecords];
            records.count should equal(limit);
//            expect([records count]).toEqual(limit);
        });
        it(@"OFFSET should return records from third record", ^{
            NSInteger offset = 3;
            NSArray *records = [[[User lazyFetcher] offset:offset] fetchRecords];
            User *first = [records first];
            first.id.integerValue should equal(offset + 1);
//            expect(first.id.integerValue).toEqual(offset + 1);
        });
        it(@"LIMIT/OFFSET should return 5 records starts from 3-d", ^{
            NSInteger limit = 5;
            NSInteger offset = 3;
            NSArray *records = [[[[User lazyFetcher] limit:limit] offset:offset] fetchRecords];
            User *first = [records first];
            first.id.integerValue should equal(offset + 1);
            records.count should equal(limit);
//            expect(first.id.integerValue).toEqual(offset + 1);
//            expect(records.count).toEqual(limit);
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
            sortCorrect should BeTruthy();
//            expect(sortCorrect).toEqual(YES);
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
            sortCorrect should BeTruthy();
//            expect(sortCorrect).toEqual(YES);
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
            sortCorrect should BeTruthy();
//            expect(sortCorrect).toEqual(YES);
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
            sortCorrect should BeTruthy();
//            expect(sortCorrect).toEqual(YES);
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
                john.save should BeTruthy();
//                expect([john save]).toEqual(YES);
                User *alex = [User newRecord];
                alex.name = @"Alex";
                alex.createdAt = [NSDate dateWithTimeIntervalSinceNow:-DAY];
                alex.save should BeTruthy();
//                expect([alex save]).toEqual(YES);
                ARLazyFetcher *fetcher = [User lazyFetcher];
                [fetcher where:
                 @"createdAt BETWEEN %@ AND %@",
                 startDate,
                 endDate, nil];
                NSArray *users = [fetcher fetchRecords];
                users.count should equal(1);
//                expect(users.count).toEqual(1);
                [alex release];
                [john release];
                
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
                User *founded = [[fetcher fetchRecords] first];
                founded.name should equal(username);
//                expect(founded.name).toEqual(username);
            });
            it(@"whereField notEqualToValue should not find record", ^{
                NSString *username = @"john";
                User *john = [User newRecord];
                john.name = username;
                [john save];
                ARLazyFetcher *fetcher = [User lazyFetcher];
                [fetcher where:@"name <> %@", username, nil];
                User *founded = [[fetcher fetchRecords] first];
                founded.name should_not equal(username);
//                expect(founded.name).Not.toEqual(username);
            });
            it(@"WhereField in should find record", ^{
                NSString *username = @"john";
                NSArray *names = [NSArray arrayWithObjects:@"alex", username, @"peter", nil];
                User *john = [User newRecord];
                john.name = username;
                [john save];
                ARLazyFetcher *fetcher = [User lazyFetcher];
                [fetcher where:@"name in %@", names, nil];
                User *founded = [[fetcher fetchRecords] first];
                founded.name should equal(username);
//                expect(founded.name).toEqual(username);
            });
            it(@"WhereField notIn should not find record", ^{
                NSString *username = @"john";
                NSArray *names = [NSArray arrayWithObjects:@"alex", username, @"peter", nil];
                User *john = [User newRecord];
                john.name = username;
                [john save];
                ARLazyFetcher *fetcher = [User lazyFetcher];
                [fetcher where:@"name not in %@", names, nil];
                User *founded = [[fetcher fetchRecords] first];
                founded.name should_not equal(username);
//                expect(founded.name).Not.toEqual(username);
            });
            it(@"WhereField LIKE should find record", ^{
                NSString *username = @"john";
                User *john = [User newRecord];
                john.name = username;
                [john save];
                ARLazyFetcher *fetcher = [User lazyFetcher];
                [fetcher where:@"name like %@", @"%jo%", nil];
                User *founded = [[fetcher fetchRecords] first];
                founded.name should equal(username);
//                expect(founded.name).toEqual(username);
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
                idStatementSuccess should BeTruthy();
                nameStatementSuccess should BeTruthy();
//                expect(idStatementSuccess).toEqual(YES);
//                expect(nameStatementSuccess).toEqual(YES);
            });
        });
    });
    
    describe(@"Where conditions", ^{
        describe(@"where between", ^{
            it(@"should fetch only records between two dates", ^{
                [ActiveRecord clearDatabase];
                NSDate *startDate = [NSDate dateWithTimeIntervalSinceNow:-MONTH];
                NSDate *endDate = [NSDate dateWithTimeIntervalSinceNow:DAY];
                User *john = [User newRecord];
                john.name = @"John";
                john.createdAt = [NSDate dateWithTimeIntervalSinceNow:-MONTH * 2];
                john.save should BeTruthy();
                User *alex = [User newRecord];
                alex.name = @"Alex";
                alex.createdAt = [NSDate dateWithTimeIntervalSinceNow:-DAY];
                alex.save should BeTruthy();
                ARLazyFetcher *fetcher = [User lazyFetcher];
                objc_msgSend(fetcher,
                             sel_getUid("whereField:between:and:"),
                             @"createdAt",
                             startDate,
                             endDate);
//  CoStyle
//                [fetcher whereField:@"createdAt"
//                            between:startDate
//                                and:endDate];
                NSArray *users = [fetcher fetchRecords];
                users.count should equal(1);
                [alex release];
                [john release];
                
            });
        });
        describe(@"Simple where conditions", ^{
            it(@"whereField equalToValue should find record", ^{
                NSString *username = @"john";
                User *john = [User newRecord];
                john.name = username;
                [john save];
                ARLazyFetcher *fetcher = [User lazyFetcher];
                [fetcher whereField:@"name" equalToValue:username];
                User *founded = [[fetcher fetchRecords] first];
                founded.name should equal(username);
            });
            it(@"whereField notEqualToValue should not find record", ^{
                NSString *username = @"john";
                User *john = [User newRecord];
                john.name = username;
                [john save];
                ARLazyFetcher *fetcher = [User lazyFetcher];
                [fetcher whereField:@"name" notEqualToValue:username];
                User *founded = [[fetcher fetchRecords] first];
                founded.name should_not equal(username);
            });
            it(@"WhereField in should find record", ^{
                NSString *username = @"john";
                NSArray *names = [NSArray arrayWithObjects:@"alex", username, @"peter", nil];
                User *john = [User newRecord];
                john.name = username;
                [john save];
                ARLazyFetcher *fetcher = [User lazyFetcher];
                [fetcher whereField:@"name" in:names];
                User *founded = [[fetcher fetchRecords] first];
                founded.name should equal(username);
            });
            it(@"WhereField notIn should not find record", ^{
                NSString *username = @"john";
                NSArray *names = [NSArray arrayWithObjects:@"alex", username, @"peter", nil];
                User *john = [User newRecord];
                john.name = username;
                [john save];
                ARLazyFetcher *fetcher = [User lazyFetcher];
                [fetcher whereField:@"name" notIn:names];
                User *founded = [[fetcher fetchRecords] first];
                founded.name should_not equal(username);
            });
            it(@"WhereField LIKE should find record", ^{
                NSString *username = @"john";
                User *john = [User newRecord];
                john.name = username;
                [john save];
                ARLazyFetcher *fetcher = [User lazyFetcher];
                [fetcher whereField:@"name"
                               like:@"%jo%"];
                User *founded = [[fetcher fetchRecords] first];
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
                
                ARWhereStatement *nameStatement = [ARWhereStatement whereField:@"name"
                                                                      ofRecord:NSClassFromString(@"User")
                                                                  equalToValue:username];
                ARWhereStatement *idStatement = [ARWhereStatement whereField:@"id"
                                                                    ofRecord:NSClassFromString(@"User")
                                                                          in:ids];
                
                ARWhereStatement *finalStatement = [ARWhereStatement concatenateStatement:nameStatement
                                                                            withStatement:idStatement
                                                                      useLogicalOperation:ARLogicalOr];
                
                ARLazyFetcher *fetcher = [User lazyFetcher];
                [fetcher setWhereStatement:finalStatement];
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
                idStatementSuccess should BeTruthy();
                nameStatementSuccess should BeTruthy();
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
            User *user = [[fetcher fetchRecords] last];
            user.groupId should BeNil();
        });
        it(@"except should return only not listed fields", ^{
            ARLazyFetcher *fetcher = [[User lazyFetcher] except:@"name", nil];
            User *john = [User newRecord];
            john.name = @"john";
            john.groupId = [NSNumber numberWithInt:145];
            [john save];
            User *user = [[fetcher fetchRecords] last];
            user.name should BeNil();
        });
    });
});

SPEC_END
