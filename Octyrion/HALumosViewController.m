#import "HALumosViewController.h"
#define REGION_RADIUS 100

enum HARemoteState {
  HARemoteFetchLogin,
  HARemotePostLogin,
  HARemoteFetchScenes,
  HARemotePerformLogout
};

@interface HALumosViewController ()

@property (nonatomic, strong, readwrite) NSString *baseURL;
@property (nonatomic, strong, readwrite) NSMutableURLRequest *req;
@property (nonatomic, strong, readwrite) UIWebView *webView;
@property (nonatomic, assign) enum HARemoteState remoteState;

@property (strong, nonatomic) CLLocationManager *locationManager;

@end

@implementation HALumosViewController

- (void)viewDidLoad
{
  [super viewDidLoad];

  // Do any additional setup after loading the view, typically from a nib.
  FCColorPickerViewController *colorPicker = [[FCColorPickerViewController alloc]
                                              initWithNibName:@"FCColorPickerViewController"
                                              bundle:[NSBundle mainBundle]];
  
  colorPicker.color = self.view.backgroundColor;
  colorPicker.delegate = self;
  
  [colorPicker setModalPresentationStyle:UIModalPresentationFormSheet];
  [self presentViewController:colorPicker animated:YES completion:nil];
  
  [self initializeLocationManager];

  self.baseURL = @"http://www.meethue.com/en-US";
  self.webView = [[UIWebView alloc] initWithFrame:CGRectZero];
  self.webView.delegate = self;

  [self beginLogin];
}

-(void)colorPickerViewController:(FCColorPickerViewController *)colorPicker didSelectColor:(UIColor *)color {
  self.view.backgroundColor = color;
  [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)colorPickerViewControllerDidCancel:(FCColorPickerViewController *)colorPicker {
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
  return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
  //
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
  NSLog(@"didFailLoadWithError: %@", error);
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
  NSString *result;
  NSString *fetchDataScript = @"(function(global){"
    "return JSON.stringify(global.app.data);"
  "})(window, JSON);";

  switch (self.remoteState) {
    case HARemoteFetchLogin:
      [self postLogin];
      break;
    case HARemotePostLogin:
      result = [webView stringByEvaluatingJavaScriptFromString:
        @"document.body.innerHTML"
      ];
      // NSLog(@"PostLogin resp = %@", result);
      [self fetchScenes];
      break;
    case HARemoteFetchScenes:
      result = [webView stringByEvaluatingJavaScriptFromString:fetchDataScript];
      NSLog(@"Data resp = %@", result);
      [self logout];
      break;
    case HARemotePerformLogout:
      result = [webView stringByEvaluatingJavaScriptFromString:
        @"document.body.innerHTML"
      ];
      // NSLog(@"Logout resp = %@\n", result);
      break;
  }
}

- (void)beginLogin
{
  self.remoteState = HARemoteFetchLogin;

  NSString *login = [self.baseURL stringByAppendingPathComponent:@"login"];
  self.req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:login]];

  [self.webView loadRequest:self.req];
}

- (void)postLogin
{
  self.remoteState = HARemotePostLogin;

  NSString *username = @"kourge@gmail.com";
  NSString *password = @"Emancipation!";

  NSString *script = @"(function(){"
    "var email = document.getElementById('email');"
    "var password = document.getElementById('password');"
    "email.value = '%@';"
    "password.value = '%@';"
    "var form = document.getElementsByTagName('form')[0];"
    "form.submit();"
  "})();";

  NSString *injection = [NSString stringWithFormat:script, username, password];

  [self.webView stringByEvaluatingJavaScriptFromString:injection];
}

- (void)fetchScenes
{
  self.remoteState = HARemoteFetchScenes;

  NSString *scenes = [self.baseURL stringByAppendingPathComponent:@"user/scenes"];
  [self.req setURL:[NSURL URLWithString:scenes]];
  [self.req setHTTPMethod:@"GET"];

  [self.webView loadRequest:self.req];
}

- (void)logout
{
  self.remoteState = HARemotePerformLogout;

  NSString *logout = [self.baseURL stringByAppendingPathComponent:@"auth/logout"];
  [self.req setURL:[NSURL URLWithString:logout]];
  [self.req setHTTPMethod:@"GET"];

  [self.webView loadRequest:self.req];
}

- (void)initializeLocationManager {
  if (nil == self.locationManager)
    self.locationManager = [[CLLocationManager alloc] init];
  
  CLLocationManager *locationManager = self.locationManager;
  locationManager.delegate = self;
  
  [self.locationManager startUpdatingLocation];
}

- (BOOL)hardwareDoesSupport
{
  return [CLLocationManager regionMonitoringAvailable];
}

- (BOOL)permissionUnauthorized
{
  CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
  
  if (status == kCLAuthorizationStatusAuthorized ||
      status == kCLAuthorizationStatusNotDetermined)
    return YES;
  return NO;
}

- (void)setCurrentLocationAsHome {
  NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
  NSNumber *latitude, *longitude;
  
  // get stored home location
  NSDictionary *dict = [prefs dictionaryForKey:@"homeLocation"];
  
  // if stored location exists, stop monitoring it
  if (dict != nil) {
    latitude = [dict objectForKey:@"latitude"];
    longitude = [dict objectForKey:@"longitude"];
    
    CLLocationCoordinate2D oldLocation = { .latitude = [latitude doubleValue], .longitude = [longitude doubleValue] };
    
    CLRegion *old = [[CLRegion alloc] initCircularRegionWithCenter:oldLocation radius:REGION_RADIUS identifier:@"home"];
    
    [self.locationManager stopMonitoringForRegion:old];
    [self messagePrefix:@"Stopped monitoring" withRegion:old];
  }
  
  // get current location
  CLLocationCoordinate2D currentLocation = [[self.locationManager location] coordinate];
  CLRegion *reg = [[CLRegion alloc] initCircularRegionWithCenter:currentLocation radius:REGION_RADIUS identifier:@"home"];
  
  // start monitoring current location
  [self.locationManager startMonitoringForRegion:reg];

  latitude = [[NSNumber alloc] initWithDouble:currentLocation.latitude];
  longitude = [[NSNumber alloc] initWithDouble:currentLocation.longitude];
  
  // save current location
  [prefs setObject:@{@"latitude" : latitude, @"longitude" : longitude} forKey:@"homeLocation"];
   
  // make sure data is stored
  [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
  [self messagePrefix:@"Entering" withRegion:region];
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
  [self messagePrefix:@"Exiting" withRegion:region];
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
  [self messagePrefix:@"Started monitoring" withRegion:region];
}

- (void)messagePrefix:(NSString*)str withRegion:(CLRegion *)region
{
  CLLocationDegrees lat = [region center].longitude;
  CLLocationDegrees lon = [region center].latitude;
  NSLog(@" %@ latitude = %f, longitude = %f\n", str, lat, lon);
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

@end
