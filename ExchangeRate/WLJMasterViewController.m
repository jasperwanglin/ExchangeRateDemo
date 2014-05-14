//
//  WLJMasterViewController.m
//  ExchangeRate
//
//  Created by WL on 14-5-13.
//  Copyright (c) 2014年 WLJ. All rights reserved.
//

#import "WLJMasterViewController.h"
#import "WLJCountryTableViewCell.h"
#import "WLJCountyListTableViewController.h"

#import "WLJDetailViewController.h"

#define REUSED_CELL_IDENTIFIER @"countryTableViewCellIdentifier"

@interface WLJMasterViewController () {
    NSMutableArray *_objects;
    int inputRow;
    BOOL haveChange;
    NSString *needExchangeMoney;
    double RMB;
}
@end

@implementation WLJMasterViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    inputRow = -1;//初始化
    haveChange = NO;//初始化
    RMB = 0;//初始化

    //已经选择的国家数组，之后从文件中读取
    self.selectedCountry = [[NSMutableArray alloc] init];
    
    //各个国家对应的汇率
    self.countryNameRate = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:0.16], @"America", [NSNumber numberWithDouble:1], @"China", [NSNumber numberWithDouble:0.095], @"England", [NSNumber numberWithDouble:0.116], @"Germany", [NSNumber numberWithDouble:0.116], @"Holland", [NSNumber numberWithDouble:1.244], @"HongKong", [NSNumber numberWithDouble:16.424], @"Japan", [NSNumber numberWithDouble:164.082], @"Korea", [NSNumber numberWithDouble:144.422], @"North Korea", [NSNumber numberWithDouble:7.029], @"Philippines", [NSNumber numberWithDouble:0.116], @"Portugal", [NSNumber numberWithDouble:5.599], @"Russia", [NSNumber numberWithDouble:0.1425], @"Switzerland", [NSNumber numberWithDouble:12.361], @"Mongolia", [NSNumber numberWithDouble:0.116], @"Turkey",[NSNumber numberWithDouble:0.6], @"Brunei",[NSNumber numberWithDouble:1.26], @"Bangladesh", nil];
    
    self.countryTag = [[NSMutableArray alloc] init];
    for (int i = 0; i < [self.countryNameRate count]; i++) {
        NSNumber *tag = [NSNumber numberWithBool:NO];
        [self.countryTag addObject:tag];
    }

    //注册表单元
    [self.tableView registerClass:[WLJCountryTableViewCell class] forCellReuseIdentifier:REUSED_CELL_IDENTIFIER];
    
    //添加货币按钮
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [addButton setBackgroundImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
    [addButton addTarget:self action:@selector(add) forControlEvents:UIControlEventTouchUpInside];
    addButton.frame = CGRectMake(0, 0, 30, 30);
    
    UIBarButtonItem *addBarbuttonItem = [[UIBarButtonItem alloc] initWithCustomView:addButton];
    self.navigationItem.leftBarButtonItem = addBarbuttonItem;
    
    //添加转换按钮
    UIButton *exchangeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [exchangeButton setBackgroundImage:[UIImage imageNamed:@"exchange"] forState:UIControlStateNormal];
    [exchangeButton addTarget:self action:@selector(exchange) forControlEvents:UIControlEventTouchUpInside];
    exchangeButton.frame = CGRectMake(0, 0, 30, 30);
    
    UIBarButtonItem *exchangeBarbuttonItem = [[UIBarButtonItem alloc] initWithCustomView:exchangeButton];
    self.navigationItem.rightBarButtonItem = exchangeBarbuttonItem;
    
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearTextFields:) name:ClearTextFieldNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rMBExchange:) name:FinishedTextFieldInputNotification object:nil];
}
- (void)clearTextFields:(NSNotification *)notification
{
    self.tableView.scrollEnabled = NO;
    self.navigationItem.rightBarButtonItem.customView.userInteractionEnabled = NO;
    self.navigationItem.leftBarButtonItem.customView.userInteractionEnabled = NO;
    
    NSNumber *tag = (NSNumber *)[[notification userInfo] objectForKey:SelectedTextFieldTag];
    inputRow = [tag intValue] - 1;
    for (int i = 1; i <= [self.countryTag count]; i++) {
        if (i != [tag intValue]) {
            WLJCountryTableViewCell *cell = (WLJCountryTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i-1 inSection:0]];
            cell.moneyTextField.text = nil;
        }
    }
}
//点击Done的时候接受到通知，调用
- (void)rMBExchange:(NSNotification *)notification
{
    self.navigationItem.rightBarButtonItem.customView.userInteractionEnabled = YES;
    self.navigationItem.leftBarButtonItem.customView.userInteractionEnabled = YES;
    
    //关键：haveChange要设置为NO,反之没有点击虚拟键盘中的Done的时候，数据就显示出来了
    haveChange = NO;
    //让表视图可以滚动
    self.tableView.scrollEnabled = YES;
    
    if (notification.userInfo == nil) {
        inputRow = -1;
        [self.tableView reloadData];//inputRow赋值后，重载一下视图
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Illegality Input" message:@"You must input legality numbers" delegate:nil cancelButtonTitle:@"Try Again" otherButtonTitles: nil];
        [alert show];
    }else{
        //存储金额
        NSNumber *tag = [[notification userInfo] objectForKey:TextFieldTag];
        NSString *countryName = [self.selectedCountry objectAtIndex:[tag intValue] - 1];
        double rate = [[self.countryNameRate objectForKey:countryName] doubleValue];
        
        needExchangeMoney = [[notification userInfo] objectForKey:MoneyOfTextFieldInput];
        double money = [[[notification userInfo] objectForKey:MoneyOfTextFieldInput] doubleValue];
        RMB = money / rate;
    }

}

//添加国家调用的动作
- (void)add{
    //弹出模态视图
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    WLJCountyListTableViewController *countryListViewController = [storyboard instantiateViewControllerWithIdentifier:@"CountryListTableViewController"];
    countryListViewController.delegate = self;//设置模态视图的代理
    [self presentViewController:countryListViewController animated:YES completion:nil];
}

- (void)exchange
{
    self.tableView.scrollEnabled = YES;
    if (inputRow != -1) {
//        //获得国家的名称
//        NSString *countryName = [self.selectedCountry objectAtIndex:inputRow];//非常关键
//        WLJCountryTableViewCell *cell = (WLJCountryTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:inputRow inSection:0]];
//        [cell.moneyTextField resignFirstResponder];
//        //获得输入的金额
//        NSString *money = cell.moneyTextField.text;
//        double mon = [money doubleValue];
//        //获得汇率
//        double rate = [(NSString *)[self.countryNameRate objectForKey:countryName] doubleValue];
//        //转成人民币
        
        //关键：为了滑动之后，也可以显示后面的单元，haveChange设置为YES
        haveChange = YES;
        //迭代
        double exchangeRMB = RMB;
        double exchange;
        WLJCountryTableViewCell *exchangeCell;
        NSLog(@"%f",exchangeRMB);
        //循环，显示可见的单元的转换结果
        for (int i = 0; i < [self.selectedCountry count]; i++) {
            if (i != inputRow) {
                //转换---重大bug解决，不能用exchangecell获取国家的名称，因为这时候，cell还没有显示在界面上，名称还是空的
                exchangeCell = (WLJCountryTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
                exchange = [[self.countryNameRate objectForKey:(NSString *)[self.selectedCountry objectAtIndex:i]] doubleValue];//非常关键
//                NSLog(@"%@ : %f",(NSString *)[self.countryNameRate objectForKey:exchangeCell.countryNameLabel.text], exchange);
                exchangeCell.moneyTextField.text = [NSString stringWithFormat:@"%.3f",exchangeRMB * exchange];
                NSLog(@"%d: %f * %f = %@",i ,exchangeRMB ,exchange ,[NSString stringWithFormat:@"%.3f",exchangeRMB * exchange]);
            }
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (void)insertNewObject:(id)sender
//{
//    if (!_objects) {
//        _objects = [[NSMutableArray alloc] init];
//    }
//    [_objects insertObject:[NSDate date] atIndex:0];
//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
//    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.selectedCountry count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WLJCountryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:REUSED_CELL_IDENTIFIER];
 
    //单元的设置，国旗，国名，
    cell.countryImageView.image = [UIImage imageNamed:[self.selectedCountry objectAtIndex:indexPath.row]];
    cell.countryNameLabel.text = [self.selectedCountry objectAtIndex:indexPath.row];
    cell.moneyTextField.tag = indexPath.row + 1;
    cell.moneyTextField.text = nil;
    //判断是否已经存在转化了，为了防止滚动的时候，cell重新回到界面的时候，数值不进了以及重选国家的时候，输入框都置为空
    //下面是修改1
//    if (inputRow == -1) {
//        cell.moneyTextField.text = nil;
//    }else{
//        //已经存在转换了，要重新复制
//        //先换算成人民币
////        WLJCountryTableViewCell *beExchangeCell = (WLJCountryTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:inputRow inSection:0]];
////        NSString *money = beExchangeCell.moneyTextField.text;
////        double mon = [money doubleValue];
////        NSString *countryName = (NSString *)[self.selectedCountry objectAtIndex:inputRow];
////        double rate = [[self.countryNameRate objectForKey:countryName] doubleValue];
//
//        double exchangeRMB = RMB;//mon / rate;
//        NSLog(@"人民币：%f",exchangeRMB);
//        
//        double exchange = [[self.countryNameRate objectForKey:[self.selectedCountry objectAtIndex:indexPath.row]] doubleValue];
//        NSLog(@"%f",exchange);
//        
//        cell.moneyTextField.text = [NSString stringWithFormat:@"%.3f",exchangeRMB * exchange];
//    }
    
    if (inputRow != -1 && haveChange == YES) {
        double exchangeRMB = RMB;//mon / rate;
        NSLog(@"人民币：%f",exchangeRMB);
        
        double exchange = [[self.countryNameRate objectForKey:[self.selectedCountry objectAtIndex:indexPath.row]] doubleValue];
        NSLog(@"%f",exchange);
        //要判断是因为提高用户体验，要是没有这一步的判断，用户输入的数字在滚动后重新出现在界面上的时候，会带有系统加上的小数位
        if(indexPath.row == inputRow){
            cell.moneyTextField.text = needExchangeMoney;
        }else{
            cell.moneyTextField.text = [NSString stringWithFormat:@"%.3f",exchangeRMB * exchange];
        }
    }else{
        cell.moneyTextField.text = nil;
        if (inputRow != -1 && indexPath.row == inputRow) {
            cell.moneyTextField.text = needExchangeMoney;
        }
    }
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    WLJCountryTableViewCell *deletedCell = (WLJCountryTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    NSArray *countryNameKeys = [[self.countryNameRate allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSComparisonResult result = [obj1 compare:obj2];
        return result;
    }];
    int trace = 0;
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        for (NSString *countryName in countryNameKeys) {
            if ([countryName isEqualToString: deletedCell.countryNameLabel.text]) {
                NSLog(@"%@",countryName);
                break;
            }
            trace++;
        }
        inputRow = -1;
        [self.countryTag replaceObjectAtIndex:trace withObject:[NSNumber numberWithBool:NO]];
        
        [self.selectedCountry removeAllObjects];
        for (int i= 0; i < [self.countryNameRate count]; i++) {
            if ([[self.countryTag objectAtIndex:i] boolValue] == YES) {
                [self.selectedCountry addObject:[countryNameKeys objectAtIndex:i]];
            }
        }
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.5];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}
//重载视图，当程序启动的时候或者模态视图消失的时候调用
- (void)reloadTableView{
    //初始化为没有需要转换
    inputRow = -1;
    haveChange = NO;
    //排序国家
    NSArray *countryNameList = [[self.countryNameRate allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSComparisonResult result = [obj1 compare:obj2];
        return result;
    }];
    [self.selectedCountry removeAllObjects];
    for (int i= 0; i < [self.countryNameRate count]; i++) {
        if ([[self.countryTag objectAtIndex:i] boolValue] == YES) {
            [self.selectedCountry addObject:[countryNameList objectAtIndex:i]];
        }
    }
    NSLog(@"%d",[self.selectedCountry count]);
    [self.tableView reloadData];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//    if ([[segue identifier] isEqualToString:@"showDetail"]) {
//        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
//        NSDate *object = _objects[indexPath.row];
//        [[segue destinationViewController] setDetailItem:object];
//    }
//}

@end
