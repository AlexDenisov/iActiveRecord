//
//  ARSQLBuilder.h
//  iActiveRecord
//
//  Created by Alex Denisov on 17.06.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ActiveRecord;

@interface ARSQLBuilder : NSObject

+ (const char *)sqlOnSaveRecord:(ActiveRecord *)aRecord;
+ (const char *)sqlOnUpdateRecord:(ActiveRecord *)aRecord;
+ (const char *)sqlOnDropRecord:(ActiveRecord *)aRecord;

@end
