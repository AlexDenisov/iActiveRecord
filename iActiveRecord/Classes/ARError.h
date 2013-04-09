//
//  ARError.h
//  iActiveRecord
//
//  Created by Alex Denisov on 25.03.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ARError : NSObject

@property (nonatomic, copy) NSString *modelName;
@property (nonatomic, copy) NSString *propertyName;
@property (nonatomic, copy) NSString *errorName;

- (id)initWithModel:(NSString *)aModel property:(NSString *)aProperty error:(NSString *)anError;

@end
