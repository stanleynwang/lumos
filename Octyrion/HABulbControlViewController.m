#import "HABulbControlViewController.h"
#import "HARemoteHue.h"
#import "HARemoteHueLight.h"

#define REGION_RADIUS 100

@interface HABulbControlViewController ()

@property (weak, nonatomic) FCColorPickerViewController *colorpickerVC;

@end

@implementation HABulbControlViewController

- (void)viewDidLoad
{
  [super viewDidLoad];

  HARemoteHue *hue = [HARemoteHue sharedRemoteHue];
  [hue readWithCompletion:^(HARemoteHue *hue, NSError *err) {
    if (err == nil) {
      //[hue allLightsOff];
    }
  }];
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

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

@end
