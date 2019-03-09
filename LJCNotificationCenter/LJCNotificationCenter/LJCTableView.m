//
//  LJCTableView.m
//  LJCNotificationCenter
//
//  Created by 林锦超 on 2019/3/9.
//  Copyright © 2019 林锦超. All rights reserved.
//

#import "LJCTableView.h"

@interface LJCTableView()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) NSMutableArray<NSString *> *datas;
@end
@implementation LJCTableView

- (void)dealloc
{
    [[LJCNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _datas = [NSMutableArray array];
        
        self.dataSource = self;
        self.delegate = self;
        [self registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
        
        [[LJCNotificationCenter defaultCenter] addObserver:self selector:@selector(ljcAddLineNotification:) name:LJCAddLineNotification object:@"123"];
        [[LJCNotificationCenter defaultCenter] addObserver:self selector:@selector(ljcRemoveLineNotification:) name:LJCRemoveLineNotification object:nil];
        
        // object 非空且不同(isEqual:)，不能移除
        [[LJCNotificationCenter defaultCenter] removeObserver:self name:LJCAddLineNotification object:@"1234"];
//        [[LJCNotificationCenter defaultCenter] removeObserver:self];
    }
    return self;
}

#pragma mark -
- (void)ljcAddLineNotification:(LJCNotification *)notification
{
    NSString *data = notification.userInfo[@"data"] ? notification.userInfo[@"data"] : @"";
    [self.datas addObject:data];
//    [self reloadData];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.datas.count - 1 inSection:0];
    [self insertRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationNone];
    [self scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

- (void)ljcRemoveLineNotification:(LJCNotification *)notification
{
    NSLog(@"ljcRemoveLineNotification:%@", notification);
    if ([self.datas count] == 0) {
        return;
    }
    [self.datas removeLastObject];
    [self deleteRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:self.datas.count inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.textLabel.text = _datas[indexPath.row];
    return cell;
}
@end
