//
//  ARValidatorProtocol.h
//  iActiveRecord
//
//  Created by Alex Denisov on 30.03.12.
//  Copyright (c) 2012 okolodev.org. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ActiveRecord;

@protocol ARValidatorProtocol <NSObject>

@optional
- (NSString *)errorMessage;

@required
- (BOOL)validateField:(NSString *)aField ofRecord:(ActiveRecord *)aRecord;

@end
