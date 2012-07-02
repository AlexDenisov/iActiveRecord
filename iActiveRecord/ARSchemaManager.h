//
//  ARColumnManager.h
//  iActiveRecord
//
//  Created by Alex Denisov on 01.05.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ARSchemaManager : NSObject

@property (nonatomic, retain) NSMutableDictionary *schemes;
@property (nonatomic, retain) NSMutableDictionary *indices;

+ (id)sharedInstance;

- (void)registerSchemeForRecord:(Class)aRecordClass;
- (NSArray *)columnsForRecord:(Class)aRecordClass;

- (void)addIndexOnColumn:(NSString *)aColumn ofRecord:(Class)aRecordClass;
- (NSArray *)indicesForRecord:(Class)aRecordClass;

@end
