#import "NSString+lowercaseFirst.h"

@implementation NSString (lowercaseFirst)

- (NSString *)lowercaseFirst {
  NSString *toLower = [self stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[self substringToIndex:1] lowercaseString]];
  return toLower;
}

@end
