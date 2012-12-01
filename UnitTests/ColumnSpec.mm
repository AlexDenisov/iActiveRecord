//
//  ColumnSpec.mm
//  iActiveRecord
//
//  Created by Alex Denisov on 01.08.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import "Cedar-iOS/SpecHelper.h"
#import "ARDatabaseManager.h"
#import "ActiveRecord.h"
#import "ActiveRecord_Private.h"
#import "ARColumn.h"
#import "ARColumn_Private.h"
#import "DynamicRecord.h"
#import "PrimitiveModel.h"
#import "ARColumnType.h"

using namespace Cedar::Matchers;

SPEC_BEGIN(ARColumnSpecs)

describe(@"ARColumn", ^{
        
    context(@"accessors", ^{
        
        it(@"should parse default", ^{
            objc_property_t property = class_getProperty([DynamicRecord class],
                                                         "defaultProperty");
            ARColumn *column = [[ARColumn alloc] initWithProperty:property];
            column.setter should equal(@"setDefaultProperty:");
            column.getter should equal(@"defaultProperty");
        });
        
        it(@"should parse custom", ^{
            objc_property_t property = class_getProperty([DynamicRecord class],
                                                         "customProperty");
            ARColumn *column = [[ARColumn alloc] initWithProperty:property];
            column.setter should equal(@"customSetter:");
            column.getter should equal(@"customGetter");
        });
        
    });
    
    describe(@"data types", ^{
        
        context(@"primitive", ^{
            
            NSString * const kPropertyNameKey = @"propertyName";
            NSString * const kPropertyTypeKey = @"propertyType";
            __block NSMutableDictionary *sharedContext = [SpecHelper specHelper].sharedExampleContext;
            
            sharedExamplesFor(@"primitive type", ^(NSDictionary *context){
                const char *propertyName = [[context valueForKey:kPropertyNameKey] UTF8String];
                NSInteger propertyType = [[context valueForKey:kPropertyTypeKey] integerValue];
                objc_property_t property = class_getProperty([PrimitiveModel class],
                                                             propertyName);
                property should_not BeNil();
                ARColumn *column = [[ARColumn alloc] initWithProperty:property];
                column.columnType should equal(propertyType);
                
            });
            
            it(@"char type", ^{
                [sharedContext setDictionary:@{
                           kPropertyNameKey : @"charProperty",
                           kPropertyTypeKey : @(ARColumnTypePrimitiveChar)
                 }];
                itShouldBehaveLike(@"primitive type");
            });
            
            it(@"unsigned char type", ^{
                [sharedContext setDictionary:@{
                           kPropertyNameKey : @"unsignedCharProperty",
                           kPropertyTypeKey : @(ARColumnTypePrimitiveUnsignedChar)
                 }];
                itShouldBehaveLike(@"primitive type");
            });
            
            it(@"short type", ^{
                [sharedContext setDictionary:@{
                           kPropertyNameKey : @"shortProperty",
                           kPropertyTypeKey : @(ARColumnTypePrimitiveShort)
                 }];
                itShouldBehaveLike(@"primitive type");
            });
            
            it(@"unsigned short type", ^{
                [sharedContext setDictionary:@{
                           kPropertyNameKey : @"unsignedShortProperty",
                           kPropertyTypeKey : @(ARColumnTypePrimitiveUnsignedShort)
                 }];
                itShouldBehaveLike(@"primitive type");
            });
            
            it(@"int type", ^{
                [sharedContext setDictionary:@{
                           kPropertyNameKey : @"intProperty",
                           kPropertyTypeKey : @(ARColumnTypePrimitiveInt)
                 }];
                itShouldBehaveLike(@"primitive type");
            });
            
            it(@"usngined int type", ^{
                [sharedContext setDictionary:@{
                           kPropertyNameKey : @"unsignedIntProperty",
                           kPropertyTypeKey : @(ARColumnTypePrimitiveUnsignedInt)
                 }];
                itShouldBehaveLike(@"primitive type");
            });
            
            it(@"NSInteger type", ^{
                [sharedContext setDictionary:@{
                           kPropertyNameKey : @"integerProperty",
                           kPropertyTypeKey : @(ARColumnTypePrimitiveInteger)
                 }];
                itShouldBehaveLike(@"primitive type");
            });
            
            it(@"NSUInteger type", ^{
                [sharedContext setDictionary:@{
                           kPropertyNameKey : @"unsignedIntegerProperty",
                           kPropertyTypeKey : @(ARColumnTypePrimitiveUnsignedInteger)
                 }];
                itShouldBehaveLike(@"primitive type");
            });
            
            it(@"long type", ^{
                [sharedContext setDictionary:@{
                           kPropertyNameKey : @"longProperty",
                           kPropertyTypeKey : @(ARColumnTypePrimitiveLong)
                 }];
                itShouldBehaveLike(@"primitive type");
            });
            
            it(@"unsigned long type", ^{
                [sharedContext setDictionary:@{
                           kPropertyNameKey : @"unsignedLongProperty",
                           kPropertyTypeKey : @(ARColumnTypePrimitiveUnsignedLong)
                 }];
                itShouldBehaveLike(@"primitive type");
            });
            
            it(@"long long type", ^{
                [sharedContext setDictionary:@{
                           kPropertyNameKey : @"longLongProperty",
                           kPropertyTypeKey : @(ARColumnTypePrimitiveLongLong)
                 }];
                itShouldBehaveLike(@"primitive type");
            });
            
            it(@"unsigned long long type", ^{
                [sharedContext setDictionary:@{
                           kPropertyNameKey : @"unsignedLongLongProperty",
                           kPropertyTypeKey : @(ARColumnTypePrimitiveUnsignedLognLong)
                 }];
                itShouldBehaveLike(@"primitive type");
            });
            
            it(@"NSInteger type", ^{
                [sharedContext setDictionary:@{
                           kPropertyNameKey : @"integerProperty",
                           kPropertyTypeKey : @(ARColumnTypePrimitiveInteger)
                 }];
                itShouldBehaveLike(@"primitive type");
            });
            
            it(@"float type", ^{
                [sharedContext setDictionary:@{
                           kPropertyNameKey : @"floatProperty",
                           kPropertyTypeKey : @(ARColumnTypePrimitiveFloat)
                 }];
                itShouldBehaveLike(@"primitive type");
            });
            
            it(@"double type", ^{
                [sharedContext setDictionary:@{
                           kPropertyNameKey : @"doubleProperty",
                           kPropertyTypeKey : @(ARColumnTypePrimitiveDouble)
                 }];
                itShouldBehaveLike(@"primitive type");
            });
            
            it(@"bool type", ^{
                [sharedContext setDictionary:@{
                           kPropertyNameKey : @"boolProperty",
                           kPropertyTypeKey : @(ARColumnTypePrimitiveBool)
                 }];
                itShouldBehaveLike(@"primitive type");
            });
            
        });
        
    });
    
});

SPEC_END
