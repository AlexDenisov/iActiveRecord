#import "ActiveRecord.h"
#import "ARDatabaseManager.h"
#import "NSString+lowercaseFirst.h"
#import <objc/runtime.h>
#import "ARObjectProperty.h"

#pragma mark - Dynamic functions proptotypes
NSArray* dynamicallyFind(id self, SEL _cmd, id arg);

NSArray* dynamicallyFind(id self, SEL _cmd, id arg){
    NSLog(@"dynamicallyFind resolving %@", arg);
    NSString *selector = NSStringFromSelector(_cmd);
    NSString *searchKey = [selector substringFromIndex:6];
    searchKey = [searchKey stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@":"]];
    searchKey = [searchKey lowercaseFirst];
    NSArray *records = [[ARDatabaseManager sharedInstance] allRecordsWithName:[[self class] description] 
                                                                     whereKey:searchKey 
                                                                     hasValue:arg];
    return records;
}

@implementation ActiveRecord

@synthesize id;

+ (const char *)sqlOnCreate {
    NSMutableString *sqlString = [NSMutableString stringWithFormat:@"create table %@(id integer primary key ", 
                                  [self performSelector:@selector(tableName)]];
    NSArray *properties = [self performSelector:@selector(properties)];
    if([properties count] == 0){
        return NULL;
    }
    for(ARObjectProperty *property in properties){
        [sqlString appendFormat:@", %@ %s", property.propertyName, [property sqltype]];
    }
    [sqlString appendFormat:@")"];
    return [sqlString UTF8String];
}

+ (NSString *)tableName {
    return [NSString stringWithFormat:@"ar%@", [[self class] description]];
}

+ (BOOL)resolveInstanceMethod:(SEL)name {
  NSLog(@"%@", NSStringFromSelector(name));
  return NO;
}

+ (BOOL)resolveClassMethod:(SEL)aSel {
    NSString *selectorName = NSStringFromSelector(aSel);
    if([selectorName hasPrefix:@"findBy"]){
        Class selfMetaClass = objc_getMetaClass([[[self class] description]  UTF8String]);
        class_addMethod(selfMetaClass, aSel, (IMP)dynamicallyFind, "[]@:@");
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
