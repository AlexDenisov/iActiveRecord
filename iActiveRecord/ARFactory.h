//
//  ARFactory.h
//  iActiveRecord
//
//  Created by Alex Denisov on 21.03.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import <Foundation/Foundation.h>

#warning Implement seeding for all types

@class ActiveRecord;

@interface ARFactory : NSObject

+ (NSArray *)buildFew:(NSInteger)aCount recordsNamed:(NSString *)aRecordName;
+ (NSArray *)buildFew:(NSInteger)aCount records:(Class)aRecordClass;

+ (ActiveRecord *)buildRecordWithName:(NSString *)aRecordName withSeed:(NSInteger)aSeed;
+ (ActiveRecord *)buildPropertiesOfRecord:(ActiveRecord *)aRecord withSeed:(NSInteger)aSeed;

@end
