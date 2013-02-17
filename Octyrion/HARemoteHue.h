#import "DPHue.h"

@interface HARemoteHue : NSObject<DPJSONSerializable>

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong, readonly) NSString *name;
@property (nonatomic, strong, readonly) NSString *swversion;
@property (nonatomic, strong, readonly) NSArray *lights;
@property (nonatomic, readonly) BOOL authenticated;

- (void)readFromJSONDictionary:(id)d;
- (void)readWithCompletion:(void (^)(HARemoteHue *, NSError *))block;

- (void)allLightsOff;
- (void)allLightsOn;
- (void)writeAll;

@end
