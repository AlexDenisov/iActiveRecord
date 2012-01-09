#import "ActiveRecord.h"
#import "ARDatabaseManager.h"

void dynamicallyFind(id self, SEL _cmd){
  NSLog(@"dynamicallyFind resolving");
}

@implementation ActiveRecord

@synthesize id;

+ (BOOL)resolveInstanceMethod:(SEL)name {
  NSLog(@"%@", NSStringFromSelector(name));
  return NO;
}

+ (BOOL)resolveClassMethod:(SEL)aSel {
  NSString *selectorName = NSStringFromSelector(aSel);
  if([selectorName hasPrefix:@"findBy"]){
    NSLog(@"try to resolve %@", [self class]);
    Class selfMetaClass = objc_getMetaClass([[[self class] description]  UTF8String]);
    BOOL result = class_addMethod(selfMetaClass, aSel, (IMP)dynamicallyFind, "v@:");
    NSLog(@"result %d", result);
    return YES;
  }
  return [super resolveInstanceMethod:aSel];
}

+ (id)newRecord {
  Class RecordClass = [self class];
  id record = [[RecordClass alloc] init];
  return record;
}

+ (NSArray *)allRecords {
  NSString *recordName = [[self class] description];
  return [[ARDatabaseManager sharedInstance] allRecordsWithName:recordName];
}

+ (id)findById:(NSNumber *)anId{
  NSString *recordName = [[self class] description];
  return [[ARDatabaseManager sharedInstance] findRecord:recordName byId:anId];
}

@end
