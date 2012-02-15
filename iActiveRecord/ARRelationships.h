#import "NSString+lowercaseFirst.h"

#define BELONGS_TO(class, accessor) \
  - (id)accessor{\
    NSString *class_name = @""#class"";\
    return [self belongsTo:class_name];\
  }

#define HAS_MANY(relative_class, accessor) \
    - (NSArray *)accessor{\
        NSString *class_name = @""#relative_class"";\
        NSString *stringSelector = [NSString stringWithFormat:@"findBy%@Id:", [[self class] description]];\
        SEL selector = NSSelectorFromString(stringSelector);\
        id recId = [self id];\
        Class Record = NSClassFromString(class_name);\
        NSArray *records = [Record performSelector:selector withObject:recId];\
        return records;\
    }\
    - (void)add##relative_class:(ActiveRecord *)aRecord {\
        [self addRecord:aRecord];\
    }\

#define HAS_MANY_THROUGH(relative_class, relationship, accessor) \
    - (NSArray *)accessor\
    {\
        NSString *className = @""#relative_class"";\
        NSString *relativeClassName = @""#relationship"";\
        return [self hasMany:className through:relativeClassName];\
    }\
    - (void)add##relative_class:(ActiveRecord *)aRecord {\
        NSString *className = @""#relative_class"";\
        NSString *relativeClassName = @""#relationship"";\
        [self addRecord:aRecord ofClass:className through:relativeClassName];\
    }\


