//
//  DynamicAccessorSpec.mm
//  iActiveRecord
//
//  Created by Alex Denisov on 01.08.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import "Cedar-iOS/SpecHelper.h"
#import "ARDatabaseManager.h"
#import "ARSchemaManager.h"
#import "ActiveRecord.h"
#import "ActiveRecord_Private.h"
#import "ARColumn.h"
#import "ARColumn_Private.h"
#import "DynamicRecord.h"
#import "PrimitiveModel.h"
#import "ARDynamicAccessor.h"

using namespace Cedar::Matchers;

SPEC_BEGIN(ARDynamicAccessorsSpecs)

describe(@"Dynamic properties", ^{
    
    context(@"composite properties", ^{
    
        it(@"should success set value with default accessors", ^{
            NSString *defValue = @"Default";
            DynamicRecord *record = [[DynamicRecord newRecord] autorelease];
            [record setDefaultProperty:defValue];
            record.defaultProperty should equal(defValue);
        });
        
        it(@"should success set value with custom accessors", ^{
            NSString *defValue = @"Default";
            DynamicRecord *record = [[DynamicRecord newRecord] autorelease];
            [record customSetter:defValue];
            record.customGetter should equal(defValue);
        });
        
    });
    
    context(@"primitive properties", ^{
        
        it(@"should success change value", ^{
            PrimitiveModel *primitiveModel = [PrimitiveModel new];
            int value = 42;
            primitiveModel.intProperty = value;
            primitiveModel.intProperty should equal(value);
        });
        
    });
    
});

SPEC_END
