//
//  ARErrorHelper.h
//  iActiveRecord
//
//  Created by Alex Denisov on 01.02.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import <Foundation/Foundation.h>

#define ARConcat(s1, s2) [NSString stringWithFormat:@"%@%@", s1, s2]

#define AR_Error(kARError) NSLocalizedString(ARConcat(@"ar_error_", kARError), @"")

const static NSString *const kARFieldAlreadyExists = @"already_exists";
const static NSString *const kARFieldCantBeBlank = @"cant_be_blank";
