//
//  ARRepresentationProtocol.h
//  iActiveRecord
//
//  Created by Alex Denisov on 25.03.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ARRepresentationProtocol

@required
+ (const char *)sqlType;
- (NSString *)toSql;
+ (id)fromSql:(NSString *)sqlData;

@end
