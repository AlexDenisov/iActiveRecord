#import <Foundation/Foundation.h>
#import "ARRelationships.h"

@interface ActiveRecord : NSObject
{
  NSNumber *id;
}

@property (nonatomic, retain) NSNumber *id;

+ (id)newRecord;
+ (NSArray *)allRecords;
+ (id)findById:(NSNumber *)anId;

@end
