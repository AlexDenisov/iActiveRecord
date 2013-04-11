//
//  GCDSpec.mm
//  iActiveRecord
//
//  Created by Alex Denisov on 10.04.12.
//  Copyright (c) 2012 okolodev.org. All rights reserved.
//

#import <CedarAsync/CedarAsync.h>
#import "User.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(GCDSpec)

describe(@"GCD", ^{
    
    it(@"should save records in background", ^{
        __block NSInteger count = 0;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            User *user = [User newRecord];
            user.name = @"alex";
            [user save];
            dispatch_async(dispatch_get_main_queue(), ^{
                count = [User count];
            });
        });
        
        in_time(count) should be_greater_than(0);
    });
});

SPEC_END
