//
//  NSArray+objectsAccessors.m
//  iActiveRecord
//
//  Created by Alex Denisov on 21.03.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import "NSArray+objectsAccessors.h"

@implementation NSArray (objectsAccessors)

- (id)first {
    if(self.count){
        return [self objectAtIndex:0];        
    }else{
        return nil;
    }
}

- (id)last {
    return [self lastObject];
}

@end
