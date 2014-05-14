//
//  WLJCountryTableViewCell.m
//  ExchangeRate
//
//  Created by WL on 14-5-13.
//  Copyright (c) 2014年 WLJ. All rights reserved.
//

#import "WLJCountryTableViewCell.h"

#define kImageViewheight 36.0f
#define kimageViewWidth 50.0f
#define kMarginSize 10.0f
#define kCountryNameLabelHeight 30.0f
#define kCountryNameLabelWidth 100.0f
#define kmoneyTextFieldHeight 30.0f


@implementation WLJCountryTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //国家图片视图设置
        self.countryImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kMarginSize, self.frame.size.height / 2 - kImageViewheight / 2 , kimageViewWidth, kImageViewheight)];
        self.countryImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:self.countryImageView];
        
        //国家名称显示
        self.countryNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(2*kMarginSize + kimageViewWidth, self.frame.size.height / 2 - kCountryNameLabelHeight / 2, kCountryNameLabelWidth, kCountryNameLabelHeight)];
        [self.contentView addSubview:self.countryNameLabel];
        
        //金额输入款设置
        CGFloat moneyTextFieldWidth = self.frame.size.width - 4*kMarginSize - kimageViewWidth - kCountryNameLabelWidth;
        self.moneyTextField = [[UITextField alloc] initWithFrame:CGRectMake(3*kMarginSize + kimageViewWidth + kCountryNameLabelWidth, self.frame.size.height / 2 - kCountryNameLabelHeight / 2, moneyTextFieldWidth, kmoneyTextFieldHeight)];
        self.moneyTextField.delegate = self;
        self.moneyTextField.returnKeyType = UIReturnKeyDone;
        self.moneyTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.moneyTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        self.moneyTextField.textAlignment = NSTextAlignmentRight;
        self.moneyTextField.placeholder = @"输入金额";
        [self.contentView addSubview:self.moneyTextField];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    //判断输入是否是合法的数字
    NSScanner *scan = [NSScanner scannerWithString:textField.text];
    float val;
    if ([scan scanFloat:&val] && [scan isAtEnd]) {
        //发出通知，告知视图控制器，输入今儿完成
        NSNumber *textFieldTag = [NSNumber numberWithInt:textField.tag];
        [[NSNotificationCenter defaultCenter] postNotificationName:FinishedTextFieldInputNotification object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:textField.text,MoneyOfTextFieldInput,textFieldTag,TextFieldTag, nil]];
    }else{
        //非法输入
        [[NSNotificationCenter defaultCenter] postNotificationName:FinishedTextFieldInputNotification object:self userInfo: nil];
    }
    

    
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    //发送清除其他文本框通知
    [[NSNotificationCenter defaultCenter] postNotificationName:ClearTextFieldNotification object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:textField.tag], SelectedTextFieldTag, nil]];
}

@end
