#import <UIKit/UIKit.h>
#import <FCColorPickerViewController.h>

@class HABulbControlViewController;

@protocol HABulbControlViewControllerDelegate <NSObject>

- (void)HABulbControlViewController:(HABulbControlViewController *)bulbController didSelectColor:(UIColor *)color;
- (void)HABulbControlViewControllerDidCancel:(HABulbControlViewController *)bulbController;

@end

@interface HABulbControlViewController : UIViewController<UIWebViewDelegate,ColorPickerViewControllerDelegate,UITableViewDataSource>
@property (readwrite, nonatomic, retain) UIColor *color;
@property (nonatomic,assign)	id<HABulbControlViewControllerDelegate> delegate;
@end
