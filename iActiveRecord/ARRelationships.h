#import "NSString+lowercaseFirst.h"

#define BELONGS_TO(class, accessor) \
  - (id)accessor{\
    NSString *class_name = @""#class"";\
    NSString *stringSelector = [NSString stringWithFormat:@"%@Id", [class_name lowercaseFirst]];\
    SEL selector = NSSelectorFromString(stringSelector);\
    Class Record = NSClassFromString(class_name);\
    id rec_id = [self performSelector:selector];\
    id record = [Record findById:rec_id];\
    return record;\
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
  }

#define HAS_MANY_THROUGH(relative_class, relationship, accessor) \
    - (NSArray *)groups\
    {\
        NSMutableArray *relativeObjects = [[NSMutableArray alloc] init];\
        NSArray *relationships;\
        NSString *class_name = @""#relative_class"";\
        NSString *stringSelector = [NSString stringWithFormat:@"findBy%@Id", class_name];\
        SEL selector = NSSelectorFromString(stringSelector);\
        relationships = [relationship performSelector:selector withObject:self.id];\
        NSString *relativeStringSelector = [NSString stringWithFormat:@"%@Id", [class_name lowercaseFirst]];\
        SEL relativeIdSelector = NSSelectorFromString(relativeStringSelector);\
        for(relationship *rel in relationships)\
        {\
            \
            id tmpRelativeObject = [relative_class findById:[rel performSelector:relativeIdSelector]];\
            [relativeObjects addObject:tmpRelativeObject];\
        }\
        return relativeObjects;\
    }\

