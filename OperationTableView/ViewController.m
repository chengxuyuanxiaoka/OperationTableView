//
//  ViewController.m
//  OperationTableView
//
//  Created by 一米阳光 on 2017/4/17.
//  Copyright © 2017年 一米阳光. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<
UITableViewDataSource,
UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray *arrayDS;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) BOOL isEditing;//当前状态可否编辑

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupDatas];
    [self setupSubviews];
}

- (void)setupDatas {
    self.isEditing = NO;
    self.arrayDS = [[NSMutableArray alloc] init];
    NSMutableArray * arrayBoys = [[NSMutableArray alloc] init];
    NSMutableArray * arrayGirls = [[NSMutableArray alloc] init];
    for (int i = 0; i < 20; i++) {
        NSString * str1 = [NSString stringWithFormat:@"男同学%d号",i+1];
        NSString * str2 = [NSString stringWithFormat:@"女同学%d号",i+1];
        [arrayBoys addObject:str1];
        [arrayGirls addObject:str2];
    }
    [self.arrayDS addObject:arrayBoys];
    [self.arrayDS addObject:arrayGirls];
}

- (void)setupSubviews {
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationItem.title = @"表格视图";
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 64) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    //在导航条上添加编辑按钮
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.arrayDS count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[_arrayDS objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ///<1.>设置标识符
    static NSString * str = @"cellID";
    ///<2.>根据这个标识符 去队列里面找一找用木有空余的
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:str];
    ///<3.>如果cell不存在，则新建cell
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:str];
    }
    ///<4.>设置信息、刷新数据
    cell.textLabel.text = _arrayDS[indexPath.section][indexPath.row];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"男同学";
    } else {
        return @"女同学";
    }
}

/**
 *  点击编辑按钮,开启当前表格的编辑状态
 */
- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    //1、调用父类中的setEditing方法
    [super setEditing:editing animated:animated];
    //2、将标识表格编辑状态的变量变为相反值
    _isEditing = !_isEditing;
    //3、开启/关闭表格的编辑状态
    [_tableView setEditing:_isEditing animated:YES];
}

/**
 *  设置单元格的编辑样式(默认情况下单元格的编辑样式为删除样式)
 */
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return UITableViewCellEditingStyleDelete;
    } else {
        return UITableViewCellEditingStyleInsert;
    }
}

/**
 *  实现删除、添加单元格操作
 *  删除操作,先删除数组中的元素,再删除相应索引处的单元格
 *  添加操作,先在数组中插入元素,再在相应索引处插入新的单元格
 */
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //获取删除的元素(单元格)处于哪个分区
        NSMutableArray * arrDelete = [_arrayDS objectAtIndex:indexPath.section];
        //根据分区的区号来删除对应数组中的元素
        [arrDelete removeObjectAtIndex:indexPath.row];
        /**
         *  从表格上删除单元格
         *  第一个参数：添加的是删除单元格所在区域的数组
         *  第二个参数：添加的删除单元格带有的动画效果
         */
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        //获取添加的元素（单元格）处于哪个分区
        NSMutableArray * arrayInsert = [_arrayDS objectAtIndex:indexPath.section];
        //向数组添加元素
        [arrayInsert insertObject:@"new" atIndex:indexPath.row];
        /**
         *  在表格的相应索引处添加单元格
         *  第一个参数：添加的是删除单元格所在区域的数组
         *  第二个参数：添加的删除单元格带有的动画效果
         */
        [tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    }
}

/**
 *  设置单元格移动样式
 */
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

/**
 *  第二个参数：表示将要移动的单元格所处的位置
 *  第三个参数：表示移动到哪个位置
 */
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    //获取需要删除的元素数组
    NSMutableArray * arrayDelete = [_arrayDS objectAtIndex:sourceIndexPath.section];
    //保存删除的元素内容
    NSString * str = [arrayDelete objectAtIndex:sourceIndexPath.row];
    //从数组中删除该元素
    [arrayDelete removeObjectAtIndex:sourceIndexPath.row];
    //获取添加元素所在的数组
    NSMutableArray * arrayInsert = [_arrayDS objectAtIndex:destinationIndexPath.section];
    [arrayInsert insertObject:str atIndex:destinationIndexPath.row];
}

@end
