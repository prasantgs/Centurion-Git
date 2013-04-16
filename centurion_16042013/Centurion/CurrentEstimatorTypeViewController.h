//
//  CurrentEstimatorTypeViewController.h
//  Centurion
//
//  Created by c on 11/15/12.
//
//

#import <UIKit/UIKit.h>

@interface CurrentEstimatorTypeViewController : UIViewController{
    
    NSString *str_CurEstNavTitle;
    NSString *str_ProductType;
    IBOutlet UITextField *txt_centurionProCost;
    IBOutlet UITextField *txt_currentProCost;
    IBOutlet UITextField *txt_hourlyPVI;

}
@property (nonatomic, retain) NSString *str_CurEstNavTitle;

-(IBAction)RadioButton_Clicked:(id)sender;
-(IBAction)CancelPressed:(id)sender;
-(IBAction)SaveButtonPressed:(id)sender;
@end
