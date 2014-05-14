//
//  WLJCountryTableViewCell.h
//  ExchangeRate
//
//  Created by WL on 14-5-13.
//  Copyright (c) 2014年 WLJ. All rights reserved.
//

#import <UIKit/UIKit.h>

#define ClearTextFieldNotification @"ClearTextFieldNotification"
#define SelectedTextFieldTag @"userInfo"
#define FinishedTextFieldInputNotification @"finishedTextFieldInput"
#define MoneyOfTextFieldInput @"moneyOfTextFiedInput"
#define TextFieldTag @"textFieldTag"

@interface WLJCountryTableViewCell : UITableViewCell <UITextFieldDelegate>

@property (nonatomic, strong) UITextField *moneyTextField;
@property (nonatomic, strong) UIImageView *countryImageView;
@property (nonatomic, strong) UILabel *countryNameLabel;

@end
