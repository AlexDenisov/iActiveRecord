#import "ActiveRecord.h"
#import "ARDatabaseManager.h"
#import "NSString+lowercaseFirst.h"

NSArray* dynamicallyFind(id self, SEL _cmd, id arg){
  NSLog(@"dynamicallyFind resolving %@", arg);
  NSString *selector = NSStringFromSelector(_cmd);
  NSString *searchKey = [selector substringFromIndex:6];
  searchKey = [searchKey stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@":"]];
  searchKey = [searchKey lowercaseFirst];
  NSArray *records = [[ARDatabaseManager sharedInstance] allRecordsWithName:[[self class] description] whereKey:searchKey hasValue:arg];
  return records;
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
    BOOL result = class_addMethod(selfMetaClass, aSel, (IMP)dynamicallyFind, "[]@:@");
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
