//
//  WLJCountyListTableViewController.m
//  ExchangeRate
//
//  Created by WL on 14-5-13.
//  Copyright (c) 2014年 WLJ. All rights reserved.
//

#import "WLJCountyListTableViewController.h"
#import "WLJMasterViewController.h"

#define kImageViewheight 36.0f
#define kimageViewWidth 50.0f
#define kMarginSize 10.0f
#define kCountryNameLabelHeight 30.0f
#define kCountryNameLabelWidth 100.0f
#define kmoneyTextFieldHeight 30.0f

@interface WLJCountyListTableViewController ()

//@property (nonatomic, strong)UILabel *countryNameLabel;
//@property (nonatomic, strong)UILabel *rateLabel;
//@property (nonatomic, strong)UIImageView *countryImageView;
@end

@implementation WLJCountyListTableViewController

static NSString *reuseCellIdentifier = @"reuseCellIdentifier";
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:reuseCellIdentifier];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[(WLJMasterViewController *)self.delegate countryNameRate] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 60.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerViewInSection = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 50)];
    
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [addButton setBackgroundImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
    [addButton addTarget:self action:@selector(addCountry) forControlEvents:UIControlEventTouchUpInside];
    addButton.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 40, 25, 30, 30);
    [headerViewInSection addSubview:addButton];
    return headerViewInSection;
}

- (void)addCountry{
    //重载表视图数据，通过代理调用
    if ([self.delegate respondsToSelector:@selector(reloadTableView)]) {
        [self.delegate reloadTableView];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseCellIdentifier forIndexPath:indexPath];
    for (UIView *subView in [cell.contentView subviews]) {
        [subView removeFromSuperview];
    }
    NSArray *countyNameList = [[[self.delegate countryNameRate] allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSComparisonResult result = [obj1 compare:obj2];
        return result;
    }];
    //标志
    if ([[[(WLJMasterViewController *)self.delegate countryTag] objectAtIndex:indexPath.row] boolValue] == YES) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    //添加国旗
    UIImageView *countryImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kMarginSize, cell.frame.size.height / 2 - kImageViewheight / 2 , kimageViewWidth, kImageViewheight)];
    countryImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    countryImageView.image = [UIImage imageNamed:(NSString *)[countyNameList objectAtIndex:indexPath.row]];
    [cell.contentView addSubview:countryImageView];
    
    //添加国家名称
    
    UILabel *countryNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(2*kMarginSize + kimageViewWidth, cell.frame.size.height / 2 - kCountryNameLabelHeight / 2, kCountryNameLabelWidth, kCountryNameLabelHeight)];
//    countryNameLabel.backgroundColor = [UIColor redColor];
    countryNameLabel.textAlignment = NSTextAlignmentLeft;

    countryNameLabel.text = [countyNameList objectAtIndex:indexPath.row];
    [cell.contentView addSubview:countryNameLabel];
    
    //添加汇率
    
    
    CGFloat rateLabelWidth = cell.frame.size.width - 6*kMarginSize - kimageViewWidth - kCountryNameLabelWidth;
    UILabel * rateLabel = [[UILabel alloc] initWithFrame:CGRectMake(3*kMarginSize + kimageViewWidth + kCountryNameLabelWidth, cell.frame.size.height / 2 - kCountryNameLabelHeight / 2, rateLabelWidth, kmoneyTextFieldHeight)];
//    rateLabel.backgroundColor = [UIColor redColor];
    rateLabel.textAlignment = NSTextAlignmentRight;
    NSString *exchangeRate = [NSString stringWithFormat:@"%.3f",[(NSNumber *)[[(WLJMasterViewController *)self.delegate countryNameRate] objectForKey:[countyNameList objectAtIndex:indexPath.row]] doubleValue]];
    
    rateLabel.text = exchangeRate;
    [cell.contentView addSubview:rateLabel];
    
//    //曾经选中过的单元要标记出来
//    if([[[(WLJMasterViewController *)self.delegate countryTag] objectAtIndex:indexPath.row] boolValue] == YES){
//        cell.accessoryType = UITableViewCellAccessoryCheckmark;
//    }
    return cell;
}
- (NSComparisonResult)compareKey{
    return NSOrderedAscending;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.accessoryType == UITableViewCellAccessoryNone) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [[(WLJMasterViewController *)self.delegate countryTag] replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithBool:YES]];
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
                [[(WLJMasterViewController *)self.delegate countryTag] replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithBool:NO]];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
