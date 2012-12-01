//
//  ARColumn.h
//  iActiveRecord
//
//  Created by Alex Denisov on 29.04.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ARColumn : NSObject

@property (nonatomic, copy, readonly) NSString *columnName;
@property (nonatomic, copy, readonly) Class columnClass;
@property (nonatomic, copy, readonly) Class recordClass;
@property (nonatomic, copy, readonly) NSString *getter;
@property (nonatomic, copy, readonly) NSString *setter;
@property (nonatomic, readwrite, getter = isDynamic) BOOL dynamic;

@end
