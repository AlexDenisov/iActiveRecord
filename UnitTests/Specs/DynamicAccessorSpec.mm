//
//  DynamicAccessorSpec.mm
//  iActiveRecord
//
//  Created by Alex Denisov on 01.08.12.
//  Copyright (c) 2012 okolodev.org. All rights reserved.
//

#import "SpecHelper.h"

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

beforeEach(^{
    prepareDatabaseManager();
});

describe(@"Dynamic properties", ^{
    
    context(@"composite properties", ^{
    
        it(@"should success set value with default accessors", ^{
            NSString *defValue = @"Default";
            DynamicRecord *record = [DynamicRecord newRecord] ;
            [record setDefaultProperty:defValue];
            record.defaultProperty should equal(defValue);
        });
        
        it(@"should success set value with custom accessors", ^{
            NSString *defValue = @"Default";
            DynamicRecord *record = [DynamicRecord newRecord] ;
            [record customSetter:defValue];
            record.customGetter should equal(defValue);
        });
        
        it(@"should correct set properties for different objects", ^{
            DynamicRecord *record1 = [DynamicRecord newRecord];
            DynamicRecord *record2 = [DynamicRecord newRecord];
            
            NSString *firstValue = @"FirstValue";
            NSString *secondValue = @"SecondValue";
            
            record1.defaultProperty = firstValue;
            record2.defaultProperty = secondValue;
            
            record1.defaultProperty should equal(firstValue);
            record2.defaultProperty should equal(secondValue);
        });
        
    });
    
    context(@"primitive properties", ^{
        
        __block PrimitiveModel *model;
        
        beforeEach(^{
           model = [PrimitiveModel new];
        });
        
        afterEach(^{
            [model release];
        });
        
        it(@"integer value", ^{
            int value = -42;
            model.intProperty = value;
            model.intProperty should equal(value);
        });
        
        it(@"unsigned integer value", ^{
            uint value = 42;
            model.unsignedIntProperty = value;
            model.unsignedIntProperty should equal(value);
        });
        
        it(@"NSInteger value", ^{
            NSInteger value = -42;
            model.integerProperty = value;
            model.integerProperty should equal(value);
        });
        
        it(@"NSUInteger value", ^{
            NSUInteger value = 42;
            model.unsignedIntegerProperty = value;
            model.unsignedIntegerProperty should equal(value);
        });
        
        it(@"char value", ^{
            char value = -42;
            model.charProperty = value;
            model.charProperty should equal(value);
        });
        
        it(@"unsigned char value", ^{
            unsigned char value = 42;
            model.unsignedCharProperty = value;
            model.unsignedCharProperty should equal(value);
        });
        
        it(@"short value", ^{
            short value = -42;
            model.shortProperty = value;
            model.shortProperty should equal(value);
        });
        
        it(@"unsigned short value", ^{
            unsigned char value = 42;
            model.unsignedShortProperty = value;
            model.unsignedShortProperty should equal(value);
        });
        
        it(@"long value", ^{
            long value = -42;
            model.longProperty = value;
            model.longProperty should equal(value);
        });
        
        it(@"unsigned long value", ^{
            unsigned long value = 42;
            model.unsignedLongProperty = value;
            model.unsignedLongProperty should equal(value);
        });
        
        it(@"long long value", ^{
            long long value = -42;
            model.longLongProperty = value;
            model.longLongProperty should equal(value);
        });
        
        it(@"unsigned long long value", ^{
            unsigned long long value = 42;
            model.unsignedLongLongProperty = value;
            model.unsignedLongLongProperty should equal(value);
        });
        
        it(@"float value", ^{
            float value = 42.4f;
            model.floatProperty = value;
            model.floatProperty should equal(value);
        });
        
        it(@"double value", ^{
            double value = -42.14;
            model.doubleProperty = value;
            model.doubleProperty should equal(value);
        });
        
        it(@"bool value", ^{
            BOOL value = YES;
            model.boolProperty = value;
            model.boolProperty should equal(value);
        });
        
    });
    
});

SPEC_END
