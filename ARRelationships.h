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
