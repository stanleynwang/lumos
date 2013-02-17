#import "HALumosViewController.h"
#import "HARemoteHue.h"
#import "HARemoteHueLight.h"

#define REGION_RADIUS 100

@interface HALumosViewController ()

@property (strong, nonatomic) CLLocationManager *locationManager;

@end

@implementation HALumosViewController

- (void)viewDidLoad
{
  [super viewDidLoad];

  // Do any additional setup after loading the view, typically from a nib.
  
  [self initializeLocationManager];

  HARemoteHue *hue = [[HARemoteHue alloc] init];
  [hue readWithCompletion:^(HARemoteHue *hue, NSError *err) {
    if (err == nil) {
      [hue allLightsOff];
    }
  }];
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
