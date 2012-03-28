//
//  ARValidationUniqueness.h
//  iActiveRecord
//
//  Created by Alex Denisov on 28.03.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ARValidationUniqueness : NSObject

@property (nonatomic, copy) NSString *record;
@property (nonatomic, copy) NSString *field;

- (id)initWithRecord:(NSString *)aRecord field:(NSString *)aField;

@end
