//
//  GCDSpec.mm
//  iActiveRecord
//
//  Created by Alex Denisov on 10.04.12.
//  Copyright (c) 2012 okolodev.org. All rights reserved.
//


#import "Cedar-iOS/SpecHelper.h"
#import "User.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(GCDSpec)

describe(@"GCD", ^{
    
    describe(@"should save records in background", ^{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            User *user = [User newRecord];
            user.name = @"alex";
            [user save];
            dispatch_async(dispatch_get_main_queue(), ^{
                [User count] should be_greater_than(0);
            });
        });
        [NSThread sleepForTimeInterval:0.1];
    });
});

SPEC_END
