//
//  ARValidation.h
//  iActiveRecord
//
//  Created by Alex Denisov on 31.03.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ARValidatorProtocol.h"

@interface ARValidation : NSObject

@property (nonatomic, copy) NSString *record;
@property (nonatomic, copy) NSString *field;
@property (nonatomic, retain) Class validator;

- (id)initWithRecord:(NSString *)aRecord field:(NSString *)aField validator:(Class)aValidator;

@end
