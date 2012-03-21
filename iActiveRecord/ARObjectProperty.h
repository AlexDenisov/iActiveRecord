//
//  ARObjectProperty.h
//  iActiveRecord
//
//  Created by Alex Denisov on 11.01.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@interface ARObjectProperty : NSObject

@property (nonatomic, copy) NSString *propertyName;
@property (nonatomic, copy) NSString *propertyType;
@property (nonatomic, copy) NSString *propertyAttributes;

- (id)initWithProperty:(objc_property_t)property;

@end
