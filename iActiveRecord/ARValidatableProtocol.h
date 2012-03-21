//
//  ARValidatableProtocol.h
//  iActiveRecord
//
//  Created by Alex Denisov on 01.02.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ARValidatableProtocol <NSObject>

@required
+ (void)initValidations;

@end
