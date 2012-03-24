//
//  ARFactory.m
//  iActiveRecord
//
//  Created by Alex Denisov on 21.03.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import "ARFactory.h"
#import "ActiveRecord.h"
#import "ARObjectProperty.h"

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
    NSArray *properties = [[aRecord class] performSelector:@selector(tableFields)];
    for(ARObjectProperty *property in properties){
        if([property.propertyName isEqualToString:@"id"]){
            continue;
        }
        if([property.propertyType isEqualToString:@"NSString"]){
            NSString *value = [NSString stringWithFormat:
                               @"%@_%d_%d", 
                               property.propertyName, 
                               time(0), 
                               aSeed];
            [aRecord setValue:value forKey:property.propertyName];
        }else if([property.propertyType isEqualToString:@"NSNumber"]){
            NSNumber *value = [NSNumber numberWithInt:time(0) + arc4random()%(aSeed + 1)];
            [aRecord setValue:value forKey:property.propertyName];
        }
    }
    return aRecord;
}

@end
