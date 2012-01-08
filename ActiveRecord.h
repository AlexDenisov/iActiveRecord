#import <Foundation/Foundation.h>
#import "ARRelationships.h"

@interface ActiveRecord : NSObject
{
  NSNumber *recordId;
}

@property (nonatomic, retain) NSNumber *recordId;

+ (id)newRecord;
+ (NSArray *)allRecords;
+ (id)findById:(NSNumber *)anId;

@end
