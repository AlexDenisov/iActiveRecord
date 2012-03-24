//
//  ARMigrationsHelper.h
//  iActiveRecord
//
//  Created by Alex Denisov on 01.02.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import <Foundation/Foundation.h>

#define ignore_field(aField)\
    [ActiveRecord performSelector:@selector(ignoreField:) withObject:(@""#aField"")];

#define migration_helper \
    static NSMutableSet *ignoredFields = nil;\

#define ignore_fields_do(igrnored_fileds) \
    migration_helper\
    + (void)initIgnoredFields {\
        if(nil == ignoredFields)\
            ignoredFields = [[NSMutableSet alloc] init];\
    igrnored_fileds\
}\

