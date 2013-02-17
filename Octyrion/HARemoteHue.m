#import "HARemoteHue.h"
#import "HARemoteHueLight.h"
#import "NSDictionary+Utilities.h"
#import <DPHue/DPJSONConnection.h>
#import <DPHue/DPHueLight.h>

@interface HARemoteHue ()
@property (nonatomic, strong, readwrite) NSString *baseURL;
@property (nonatomic, strong, readwrite) NSMutableURLRequest *req;
@property (nonatomic, strong, readonly) NSString *bridgeId;

@property (nonatomic, strong, readwrite) NSString *name;
@property (nonatomic, strong, readwrite) NSString *deviceType;
@property (nonatomic, strong, readwrite) NSURL *readURL;
@property (nonatomic, strong, readwrite) NSURL *writeURL;
@property (nonatomic, strong, readwrite) NSString *swversion;
@property (nonatomic, strong, readwrite) NSArray *lights;
@property (nonatomic, strong) GCDAsyncSocket *socket;
@property (nonatomic, readwrite) BOOL authenticated;

@end

@implementation HARemoteHue

- (id)init
{
  self = [super init];
  if (self) {
    self.baseURL = @"http://www.meethue.com/en-US";
  }
  return self;
}

- (void)readWithCompletion:(void (^)(HARemoteHue *, NSError *))block
{
  if (self.authenticated == NO) {
    [self fetchLoginFormWithCompletion:block];
    return;
  }
  
  NSString *scenes = [self.baseURL stringByAppendingPathComponent:@"user/scenes"];
  NSURL *scenesURL= [NSURL URLWithString:scenes];
  NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:scenesURL];
  
  DPJSONConnection *connection = [[DPJSONConnection alloc] initWithRequest:req];
  connection.completionBlock = ^(NSData *data, NSError *err) {
    if (err != nil) {
      NSString *resp = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
      NSDictionary *state = [self parseStateFromResponse:resp];
      _bridgeId = state[@"bridgeId"];
      [self readFromJSONDictionary:state[@"appData"]];
    }
    block(self, err);
  };
  [connection start];
}

- (void)fetchLoginFormWithCompletion:(void (^)(HARemoteHue *, NSError *))block
{
  NSString *login = [self.baseURL stringByAppendingPathComponent:@"login"];
  NSURL *loginURL = [NSURL URLWithString:login];
  NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:loginURL];
  
  DPJSONConnection *connection = [[DPJSONConnection alloc] initWithRequest:req];
  connection.completionBlock = ^(NSData *data, NSError *err) {
    NSString *resp = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSString *pattern = @"name=\"authenticityToken\" value=\"(.+)\"";
    NSRegularExpression *r = [NSRegularExpression
                              regularExpressionWithPattern:pattern
                              options:NSRegularExpressionCaseInsensitive
                              error:nil];
    NSTextCheckingResult *result = [r
                                    firstMatchInString:resp
                                    options:0
                                    range:NSMakeRange(0, resp.length)];
    NSRange range = [result rangeAtIndex:1];
    if (range.length == 0) {
      // *err = //;
      NSLog(@"Error in fetchLogin");
      return;
    }
    NSString *token = [resp substringWithRange:range];
    NSLog(@"token = %@", token);
    [self performLoginWithToken:token withCompletion:block];
  };
  [connection start];
}

- (void)performLoginWithToken:(NSString *)token withCompletion:(void (^)(HARemoteHue *, NSError *))block
{
  NSLog(@"performLogin");
  NSString *username = @"kourge@gmail.com";
  NSString *password = @"Emancipation!";
  
  NSString *body = [@{
                    @"authenticityToken" : token,
                    @"email" : username,
                    @"password" : password
                    } queryString];
  NSString *login = [self.baseURL stringByAppendingPathComponent:@"loginpost"];
  NSURL *loginURL= [NSURL URLWithString:[login stringByAppendingFormat:@"?%@", body]];
  NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:loginURL];
  DPJSONConnection *connection = [[DPJSONConnection alloc] initWithRequest:req];
  connection.completionBlock = ^(NSData *data, NSError *err) {
    if (err == nil) {
      NSString *resp = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
      NSDictionary *state = [self parseStateFromResponse:resp];
      _bridgeId = state[@"bridgeId"];
      [self readFromJSONDictionary:state[@"appData"]];
    }
    block(self, err);
  };
  [connection start];
}

- (NSDictionary *)parseStateFromResponse:(NSString *)response
{
  NSString *pBridgeId = @"app\\.data\\.bridgeid\\s?=\\s?\"(.+)\"";
  NSString *pAppData = @"app\\.data\\.bridge\\s?=\\s?(\\{.+\\});";
  NSRegularExpression *rBridgeId = [NSRegularExpression
                                    regularExpressionWithPattern:pBridgeId
                                    options:0
                                    error:nil];
  NSRegularExpression *rAppData = [NSRegularExpression
                                   regularExpressionWithPattern:pAppData
                                   options:0
                                   error:nil];
  NSTextCheckingResult *mBridgeId = [rBridgeId
                                     firstMatchInString:response
                                     options:0
                                     range:NSMakeRange(0, response.length)];
  NSTextCheckingResult *mAppData = [rAppData
                                    firstMatchInString:response
                                    options:0
                                    range:NSMakeRange(0, response.length)];
  NSRange rangeBridgeId = [mBridgeId rangeAtIndex:1];
  NSRange rangeAppData = [mAppData rangeAtIndex:1];
  
  if (rangeBridgeId.length == 0 || rangeAppData.length == 0)
    return nil;
  
  NSString *bridgeId = [response substringWithRange:rangeBridgeId];
  NSString *appData = [response substringWithRange:rangeAppData];
  
  return @{
           @"bridgeId" : bridgeId,
           @"appData" : [NSJSONSerialization
                         JSONObjectWithData:[appData dataUsingEncoding:NSUTF8StringEncoding]
                         options:0
                         error:nil]
  };
}

- (void)performLogout
{
  NSString *logout = [self.baseURL stringByAppendingPathComponent:@"auth/logout"];
  NSURL *logoutURL= [NSURL URLWithString:logout];
  NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:logoutURL];
  
  DPJSONConnection *connection = [[DPJSONConnection alloc] initWithRequest:req];
  connection.completionBlock = ^(NSData *data, NSError *err) {
    NSString *resp = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"logoutRresp = %@", resp);
  };
  [connection start];
}

- (void)allLightsOff {
  for (DPHueLight *light in self.lights) {
    light.on = NO;
    [light write];
  }
}

- (void)allLightsOn {
  for (DPHueLight *light in self.lights) {
    light.on = YES;
    [light write];
  }
}

- (void)writeAll {
  for (DPHueLight *light in self.lights)
    [light writeAll];
}

#pragma mark - DPJSONSerializable

- (void)readFromJSONDictionary:(id)d {
  if (![d respondsToSelector:@selector(objectForKeyedSubscript:)]) {
    // We were given an array, not a dict, which means
    // Hue is giving us a result array, which (in this case)
    // means error: not authenticated
    self.authenticated = NO;
    return;
  }
  self.name = d[@"config"][@"name"];
  if (self.name)
    self.authenticated = YES;
  self.swversion = d[@"config"][@"swversion"];
  NSMutableArray *tmpLights = [[NSMutableArray alloc] init];
  for (id lightItem in d[@"config"][@"lights"]) {
    HARemoteHueLight *light = [[HARemoteHueLight alloc] init];
    [light readFromJSONDictionary:d[@"config"][@"lights"][lightItem]];
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;
    light.baseURL = self.baseURL;
    light.number = [f numberFromString:lightItem];
    light.bridgeId = self.bridgeId;
    [tmpLights addObject:light];
  }
  self.lights = tmpLights;
}

@end
