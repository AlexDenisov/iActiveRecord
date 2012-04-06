//
//  ARJoinSpecs.h
//  iActiveRecord
//
//  Created by Alex Denisov on 06.04.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import "Cedar-iOS/SpecHelper.h"
#define EXP_SHORTHAND
#import "Expecta.h"
#import "ARDatabaseManager.h"
#import "User.h"
#import "Group.h"
#import "ARLazyFetcher.h"

SPEC_BEGIN(JoinSpecs)

beforeEach(^{
    [[ARDatabaseManager sharedInstance] clearDatabase];
});
afterEach(^{
    [[ARDatabaseManager sharedInstance] clearDatabase];
});

describe(@"Join", ^{
    beforeEach(^{
        for(int i=0;i<10;i++){
            Group *group = [Group newRecord];
            group.title = [NSString stringWithFormat:@"group%d", i];
            [group save];
            User *user = [User newRecord];
            user.name = [NSString stringWithFormat:@"user%d", i];
            user.groupId = group.id;
            [user save];
        }
    });
    it(@"should return array of dictionaries", ^{
        ARLazyFetcher *fetcher = [[User lazyFetcher] join:[Group class] 
                                                  useJoin:ARJoinInner 
                                                  onField:@"groupId" 
                                                 andField:@"id"];
        NSArray *records = [fetcher fetchJoinedRecords];
        id first = [records first];
        BOOL result = [first isKindOfClass:[NSDictionary class]];
        expect(result).toEqual(YES);
    });
    it(@"returned dictionary should contain fields of two records", ^{
        ARLazyFetcher *fetcher = [[User lazyFetcher] join:[Group class] 
                                                  useJoin:ARJoinInner 
                                                  onField:@"groupId" 
                                                 andField:@"id"];
        NSArray *records = [fetcher fetchJoinedRecords];
        NSDictionary *first = [records first];
        NSArray *keys = [first allKeys];
        BOOL result = [keys containsObject:@"title"] && [keys containsObject:@"name"];
        NSLog(@"%@", keys);
        expect(result).toEqual(YES);
    });
});

SPEC_END
