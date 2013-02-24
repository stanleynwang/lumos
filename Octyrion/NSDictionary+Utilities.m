#import "NSDictionary+Utilities.h"

@implementation NSDictionary (Utilities)

- (NSString *)queryString
{
  NSMutableArray *pairs = [NSMutableArray arrayWithCapacity:[self count]];
  for (id key in self) {
    NSString *value = [[self objectForKey:key] description];
    NSString *pair = [NSString stringWithFormat:@"%@=%@", key, [value stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [pairs addObject:pair];
  }
  return [pairs componentsJoinedByString:@"&"];
}

@end
