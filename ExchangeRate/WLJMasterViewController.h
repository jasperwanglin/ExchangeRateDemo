//
//  WLJMasterViewController.h
//  ExchangeRate
//
//  Created by WL on 14-5-13.
//  Copyright (c) 2014年 WLJ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WLJMasterViewController : UITableViewController

@property (nonatomic, strong) NSMutableArray *countryTag;//bool元素，指明选中哪些国家
@property (nonatomic, strong) NSMutableArray *selectedCountry;//存储已经选中的国家的名称
@property (nonatomic, strong) NSDictionary *countryNameRate;//每个国家的汇率

//刷新界面
- (void)reloadTableView;

@end
