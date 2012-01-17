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
    Class propertyClass = nil;
    for(ARObjectProperty *property in properties){
        propertyClass = NSClassFromString(property.propertyType);
        [sqlString appendFormat:@", %@ %s", property.propertyName, 
         [propertyClass performSelector:@selector(sqlType)]];
    }
    [sqlString appendFormat:@")"];
    return [sqlString UTF8String];
}

- (const char *)sqlOnSave {
    NSArray *properties = [[self class] performSelector:@selector(properties)];
    if([properties count] == 0){
        return NULL;
    }
    NSMutableArray *existedProperties = [[NSMutableArray alloc] init];
    ARObjectProperty *property = nil;
    for(property in properties){
        id value = [self valueForKey:property.propertyName];
        if(nil != value){
            [existedProperties addObject:property];
        }
    }
    if([existedProperties count] == 0){
        return NULL;
    }
    
    NSMutableString *sqlString = [NSMutableString stringWithFormat:@"insert into %@(", 
                                  [[self class] performSelector:@selector(tableName)]];
    NSMutableString *sqlValues = [[NSMutableString alloc] initWithFormat:@" values("];
    
    int index = 0;
    property = [existedProperties objectAtIndex:index++];
    id propertyValue = [self valueForKey:property.propertyName];
    [sqlString appendFormat:@"%@", property.propertyName];
    [sqlValues appendFormat:@"%@", [propertyValue performSelector:@selector(toSql)]];
    
    for(;index < [properties count] - 1;index++){
        property = [properties objectAtIndex:index];
        id propertyValue = [self valueForKey:property.propertyName];
        [sqlString appendFormat:@", %@", property.propertyName];
        [ sqlValues appendFormat:@", %@", [propertyValue performSelector:@selector(toSql)]];
    }
    [sqlValues appendString:@") "];
    [sqlString appendString:@") "];
    [sqlString appendString:sqlValues];
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

- (BOOL)save {
    const char *sql = [self sqlOnSave];
    if(NULL != sql){
        [[ARDatabaseManager sharedInstance] executeSqlQuery:sql];
    }
    return NO;
}

@end
