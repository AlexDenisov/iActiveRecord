//
//  DecimalRecord.h
//  iActiveRecord
//
//  Created by Marshall Weir on 4/11/13.
//
//

#import <ActiveRecord/ActiveRecord.h>

@interface DecimalRecord : ActiveRecord

@property(nonatomic, retain) NSDecimalNumber *decimal;

@end
