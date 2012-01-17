#import <Foundation/Foundation.h>
#import "ARRelationships.h"

@interface ActiveRecord : NSObject
{
    NSNumber *id;
}

@property (nonatomic, retain) NSNumber *id;

+ (const char *)sqlOnCreate;
- (const char *)sqlOnSave;

+ (NSString *)tableName;
+ (id)newRecord;
+ (NSArray *)allRecords;
+ (id)findById:(NSNumber *)anId;

- (BOOL)save;

@end
