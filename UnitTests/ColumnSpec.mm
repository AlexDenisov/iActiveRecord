//
//  ColumnSpec.mm
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
#import "ARColumnType.h"

using namespace Cedar::Matchers;

SPEC_BEGIN(ARColumnSpecs)

//beforeEach(^{
//    [[ARDatabaseManager sharedInstance] clearDatabase];
//});
//afterEach(^{
//    [[ARDatabaseManager sharedInstance] clearDatabase];
//});

describe(@"ARColumn", ^{
        
    context(@"accessors", ^{
        
        it(@"should parse default", ^{
//            [[ARSchemaManager sharedInstance] registerSchemeForRecord:[DynamicRecord class]];
            objc_property_t property = class_getProperty([DynamicRecord class],
                                                         "defaultProperty");
            ARColumn *column = [[ARColumn alloc] initWithProperty:property];
//            ARColumn *column = [DynamicRecord columnNamed:@"defaultProperty"];
            column.setter should equal(@"setDefaultProperty:");
            column.getter should equal(@"defaultProperty");
        });
        
        it(@"should parse custom", ^{
//            [[ARSchemaManager sharedInstance] registerSchemeForRecord:[DynamicRecord class]];
            objc_property_t property = class_getProperty([DynamicRecord class],
                                                         "customProperty");
            ARColumn *column = [[ARColumn alloc] initWithProperty:property];
//            ARColumn *column = [DynamicRecord columnNamed:@"customProperty"];
            column.setter should equal(@"customSetter:");
            column.getter should equal(@"customGetter");
        });
        
    });
    
    describe(@"data types", ^{
        
        context(@"primitive", ^{
            
            it(@"integer types", ^{
                objc_property_t property = class_getProperty([PrimitiveModel class],
                                                             "intProperty");
                property should_not BeNil();
                ARColumn *intColumn = [[ARColumn alloc] initWithProperty:property];
                intColumn.columnType should equal(ARColumnTypePrimitiveInteger);
            });
        });
        
    });
    
});

SPEC_END
