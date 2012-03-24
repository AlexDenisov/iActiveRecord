//
//  ARArraySpecs.h
//  iActiveRecord
//
//  Created by Alex Denisov on 21.03.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import "Cedar-iOS/SpecHelper.h"
#define EXP_SHORTHAND
#import "Expecta.h"

#import "User.h"
#import "ARDatabaseManager.h"
#import "ARFactory.h"
#import "ARWhereStatement.h"

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
        expect([records count]).toEqual(10);
    });
    it(@"allRecords should return all records", ^{ // thank, captain
        NSArray *users = [[User lazyAllRecords] fetchRecords];
        expect(users.count).toEqual([User count]);
    });
    
    describe(@"Limit/Offset", ^{
        it(@"LIMIT should return limited count of records", ^{
            NSInteger limit = 5;
            NSArray *records = [[[User lazyFetcher] limit:limit] fetchRecords];
            expect([records count]).toEqual(limit);
        });
        it(@"OFFSET should return records from third record", ^{
            NSInteger offset = 3;
            NSArray *records = [[[User lazyFetcher] offset:offset] fetchRecords];
            User *first = [records first];
            expect(first.id.integerValue).toEqual(offset + 1);
        });
        it(@"LIMIT/OFFSET should return 5 records starts from 3-d", ^{
            NSInteger limit = 5;
            NSInteger offset = 3;
            NSArray *records = [[[[User lazyFetcher] limit:limit] offset:offset] fetchRecords];
            User *first = [records first];
            expect(first.id.integerValue).toEqual(offset + 1);
            expect(records.count).toEqual(limit);
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
            expect(sortCorrect).toEqual(YES);
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
            expect(sortCorrect).toEqual(YES);
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
            expect(sortCorrect).toEqual(YES);
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
            expect(sortCorrect).toEqual(YES);
        });
    });
    
    describe(@"Where conditions", ^{
        describe(@"Simple where conditions", ^{
            it(@"whereField equalToValue should find record", ^{
                NSString *username = @"john";
                User *john = [User newRecord];
                john.name = username;
                [john save];
                ARLazyFetcher *fetcher = [User lazyFetcher];
                [fetcher whereField:@"name" equalToValue:username];
                User *founded = [[fetcher fetchRecords] first];
                expect(founded.name).toEqual(username);
            });
            it(@"whereField notEqualToValue should not find record", ^{
                NSString *username = @"john";
                User *john = [User newRecord];
                john.name = username;
                [john save];
                ARLazyFetcher *fetcher = [User lazyFetcher];
                [fetcher whereField:@"name" notEqualToValue:username];
                User *founded = [[fetcher fetchRecords] first];
                expect(founded.name).Not.toEqual(username);
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
                expect(founded.name).toEqual(username);
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
                expect(founded.name).Not.toEqual(username);
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
                                                                              equalToValue:username];
                ARWhereStatement *idStatement = [ARWhereStatement whereField:@"id" 
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
                expect(idStatementSuccess).toEqual(YES);
                expect(nameStatementSuccess).toEqual(YES); 
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
            expect(user.groupId).toBeNil();
        });
        it(@"except should return only not listed fields", ^{
            ARLazyFetcher *fetcher = [[User lazyFetcher] except:@"name", nil];
            User *john = [User newRecord];
            john.name = @"john";
            john.groupId = [NSNumber numberWithInt:145];
            [john save];
            User *user = [[fetcher fetchRecords] last];
            expect(user.name).toBeNil();
        });
    });
});

SPEC_END