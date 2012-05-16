//
//  ARWhereStatement_Private.h
//  iActiveRecord
//
//  Created by Alex Denisov on 16.05.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import "ARWhereStatement.h"

@interface ARWhereStatement ()
{
    @private
    NSString *statement;
}

+ (ARWhereStatement *)statement:(NSString *)aStmt;
+ (ARWhereStatement *)statementForField:(NSString *)aField 
                              fromArray:(NSArray *)aValues 
                          withOperation:(NSString *)anOperation;

@end
