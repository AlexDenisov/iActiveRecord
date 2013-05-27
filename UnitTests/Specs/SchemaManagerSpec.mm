//
//  SchemaManagerSpec.mm
//  iActiveRecord
//
//  Created by Alex Denisov on 01.08.12.
//  Copyright (c) 2012 okolodev.org. All rights reserved.
//

#import "SpecHelper.h"

#import "ARDatabaseManager.h"
#import "ActiveRecord_Private.h"
#import "User.h"
#import "ARSchemaManager.h"
#import "ARColumn.h"

using namespace Cedar::Matchers;

CDR_EXT
Tsuga<ARSchemaManager>::run(^{
   
    beforeEach(^{
        prepareDatabaseManager();
        [[ARDatabaseManager sharedManager] clearDatabase];
    });
    afterEach(^{
        [[ARDatabaseManager sharedManager] clearDatabase];
    });
    
    describe(@"SchemaManager", ^{
        it(@"should return nil on undefined column", ^{
            [[ARSchemaManager sharedInstance] registerSchemeForRecord:[User class]];
            ARColumn *column = [User columnNamed:@"FUUU"];
            column should BeNil();
        });
    });
    
});
