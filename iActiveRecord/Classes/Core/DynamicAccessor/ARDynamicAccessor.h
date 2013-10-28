//
//  ARDynamicAccessor.h
//  iActiveRecord
//
//  Created by Alex Denisov on 01.12.12.
//
//

#import <Foundation/Foundation.h>

@class ARColumn;

@interface ARDynamicAccessor : NSObject

+ (void)addAccessorForColumn:(ARColumn *)column;

@end
