//
//  AddEstimatorCustomCell.h
//  Centurion
//
//  Created by c on 11/14/12.
//
//

#import <UIKit/UIKit.h>

@interface AddEstimatorCustomCell : UITableViewCell{
    
    UIButton    *Btn_checkBox;
    UILabel     *lbl_EstimatorName;
}
@property (nonatomic, retain) UILabel     *lbl_EstimatorName;
@property (nonatomic, retain) UIButton    *Btn_checkBox;

@end
