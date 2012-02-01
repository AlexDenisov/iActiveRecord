//
//  ARMigrationsHelper.h
//  iActiveRecord
//
//  Created by mls on 01.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define IGNORE_FIELD(aField)\
    [ActiveRecord ignoreField:(@""#aField"")];

#define MIGRATION_HELPER \
    static NSMutableSet *ignoredFields = nil;\

#define IGNORE_FIELDS_DO(igrnored_fileds) \
    MIGRATION_HELPER\
    + (void)initIgnoredFields {\
        if(nil == ignoredFields)\
            ignoredFields = [[NSMutableSet alloc] init];\
    igrnored_fileds\
}\

