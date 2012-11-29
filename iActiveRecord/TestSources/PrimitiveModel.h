//
//  PrimitiveModel.h
//  iActiveRecord
//
//  Created by Alex Denisov on 29.11.12.
//
//

#import <ActiveRecord/ActiveRecord.h>

@interface PrimitiveModel : NSObject

// integer
@property (nonatomic, readwrite) int intProperty;
@property (nonatomic, readwrite) uint uintProperty;
@property (nonatomic, readwrite) NSInteger integerProperty;
@property (nonatomic, readwrite) NSUInteger uintegerProperty;

//  real
@property (nonatomic, readwrite) float floatProperty;
@property (nonatomic, readwrite) double doubleProperty;
@property (nonatomic, readwrite) CGFloat cgfloatProperty;

//  boolean
@property (nonatomic, readwrite) BOOL boolProperty;

@end
