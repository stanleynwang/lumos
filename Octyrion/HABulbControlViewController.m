#import "HABulbControlViewController.h"
#import "HARemoteHue.h"
#import "HARemoteHueLight.h"

#define REGION_RADIUS 100

@interface HABulbControlViewController ()

@property (weak,nonatomic) FCColorPickerViewController * colorpickerVC;
@property (weak, nonatomic) UITableViewController *bulbListVC;

@end

@implementation HABulbControlViewController

- (void)viewDidLoad
{
  [super viewDidLoad];

  HARemoteHue *hue = [[HARemoteHue alloc] init];
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
    self.colorpickerVC.delegate = self;
  } else if ([segue.identifier isEqualToString:@"bulblist_embed"]) {
      NSLog(@"down delegate");
      self.bulbListVC = segue.destinationViewController;
      self.delegate = self.bulbListVC;
//      self.bulbListVC
  }
}

-(void)colorPickerViewController:(HABulbControlViewController *)colorPicker didSelectColor:(UIColor *)color {
    NSLog(@"didSelectColor");
  self.view.backgroundColor = color;
//    self.childViewControllers
    NSLog(@"color selected: %@", colorPicker.color);
    self.color = color;
    [_delegate HABulbControlViewController:self didSelectColor:self.color];
}

-(void)colorPickerViewControllerDidCancel:(HABulbControlViewController *)colorPicker {
    NSLog(@"didCancel");
    [_delegate HABulbControlViewControllerDidCancel:self];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [tableView numberOfRowsInSection:section];
}

@end
