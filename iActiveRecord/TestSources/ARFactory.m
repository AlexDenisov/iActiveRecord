//
//  ARFactory.m
//  iActiveRecord
//
//  Created by Alex Denisov on 21.03.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import "ARFactory.h"
#import "ActiveRecord_Private.h"
#import "ARColumn.h"

@implementation ARFactory

+ (NSArray *)buildFew:(NSInteger)aCount recordsNamed:(NSString *)aRecordName {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:aCount];
    for(int i=0;i<aCount;i++){
        ActiveRecord *record = [self buildRecordWithName:aRecordName
                                                withSeed:i];
        [record save];
        [array addObject:record];
    }
    return array;
}

+ (NSArray *)buildFew:(NSInteger)aCount records:(Class)aRecordClass {
    return [self buildFew:aCount recordsNamed:[aRecordClass description]];
}

+ (ActiveRecord *)buildRecordWithName:(NSString *)aRecordName withSeed:(NSInteger)aSeed {
    Class RecordClass = NSClassFromString(aRecordName);
    ActiveRecord *record = [[RecordClass newRecord] autorelease];
    record = [self buildPropertiesOfRecord:record
                                  withSeed:aSeed];
    return record;
}

+ (ActiveRecord *)buildPropertiesOfRecord:(ActiveRecord *)aRecord withSeed:(NSInteger)aSeed {
    NSArray *columns = [[aRecord class] performSelector:@selector(columns)];
    for(ARColumn *column in columns){
        if([column.columnName isEqualToString:@"id"]){
            continue;
        }
        if([[column.columnClass description] isEqualToString:@"NSString"]){
            NSString *value = [NSString stringWithFormat:
                               @"%@_%ld_%d", 
                               column.columnName, 
                               time(0), 
                               aSeed];
            [aRecord setValue:value forKey:column.columnName];
        }else if([[column.columnClass description] isEqualToString:@"NSNumber"]){
            NSNumber *value = [NSNumber numberWithInt:time(0) + arc4random()%(aSeed + 1)];
            [aRecord setValue:value forColumn:column];
        }
    }
    return aRecord;
}

@end
