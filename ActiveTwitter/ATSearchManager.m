//
// Created by Alex Denisov on 25.05.13.
// Copyright (c) 2013 okolodev.org. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//

#import <RestKit.h>
#import "ATSearchManager.h"
#import "Tweet.h"

static NSString * const kSearchPath = @"/search.json";

@implementation ATSearchManager
{
    RKObjectManager *_backingManager;
}
// http://search.twitter.com/search.json?q=hello
- (instancetype)init {
    self = [super init];
    if (self) {
        NSURL *baseURL = [NSURL URLWithString:@"http://search.twitter.com"];
        _backingManager = [RKObjectManager managerWithBaseURL:baseURL];
        [self initializeMapping];
    }
    return self;
}

- (void)initializeMapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[Tweet class]];
    [mapping addAttributeMappingsFromArray:@[ @"text" ]];

    NSIndexSet *statusCodes = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);

    RKResponseDescriptor *descriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping
                                                                               pathPattern:kSearchPath
                                                                                   keyPath:@"results"
                                                                               statusCodes:statusCodes];
    [_backingManager addResponseDescriptor:descriptor];
}

- (void)searchForKeyword:(NSString *)keyword
             withSuccess:(SearchFinishedSuccessful)success
                 failure:(SearchFailed)failure
{
    NSDictionary *params = @{ @"q" : keyword };
    [_backingManager getObjectsAtPath:kSearchPath
                           parameters:params
                              success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                  if (success) {
                                      NSArray *result = [mappingResult array];
                                      [result makeObjectsPerformSelector:@selector(markAsNew)];
                                      success(result);
                                  }
                              }
                              failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                  if (failure) {
                                      failure(error);
                                  }
                              }];

}

@end