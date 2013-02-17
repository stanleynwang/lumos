#import "HABulbControlViewController.h"

enum HARemoteState {
  HARemoteFetchLogin,
  HARemotePostLogin,
  HARemoteFetchScenes,
  HARemotePerformLogout
};

@interface HABulbControlViewController ()

@property (nonatomic, strong, readwrite) NSString *baseURL;
@property (nonatomic, strong, readwrite) NSMutableURLRequest *req;
@property (nonatomic, strong, readwrite) UIWebView *webView;
@property (nonatomic, assign) enum HARemoteState remoteState;


@property (weak,nonatomic) FCColorPickerViewController * colorpickerVC;

@end

@implementation HABulbControlViewController

- (void)viewDidLoad
{
  [super viewDidLoad];

  self.baseURL = @"http://www.meethue.com/en-US";
  self.webView = [[UIWebView alloc] initWithFrame:CGRectZero];
  self.webView.delegate = self;

  [self beginLogin];
}

- (IBAction)settings:(id)sender {
  
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([segue.identifier isEqualToString:@"colorpicker_embed"]) {
    self.colorpickerVC = segue.destinationViewController;
  }
}

-(void)colorPickerViewController:(FCColorPickerViewController *)colorPicker didSelectColor:(UIColor *)color {
  self.view.backgroundColor = color;
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

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

@end
