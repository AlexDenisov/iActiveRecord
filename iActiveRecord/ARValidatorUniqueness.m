//
//  ARValidatorUniqueness.m
//  iActiveRecord
//
//  Created by Alex Denisov on 31.03.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import "ARValidatorUniqueness.h"
#import "ARLazyFetcher.h"
#import "ARError.h"
#import "ARErrorHelper.h"

@implementation ARValidatorUniqueness

- (BOOL)validateField:(NSString *)aField ofRecord:(id)aRecord {
    NSString *recordName = [[aRecord class] description];
    id aValue = [aRecord valueForKey:aField];
    ARLazyFetcher *fetcher = [[ARLazyFetcher alloc] initWithRecord:NSClassFromString(recordName)];
    [fetcher whereField:aField
           equalToValue:aValue];
    NSInteger count = [fetcher count];
    [fetcher release];
    if(count){
        ARError *error = [[ARError alloc] initWithModel:[aRecord performSelector:@selector(className)]
                                               property:aField
                                                  error:kARFieldAlreadyExists];
        [aRecord performSelector:@selector(addError:) 
                      withObject:error];
        [error release];
        return NO;
    }
    return YES;
}

@end
