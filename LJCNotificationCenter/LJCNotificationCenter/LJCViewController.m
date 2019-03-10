//
//  LJCViewController.m
//  LJCNotificationCenter
//
//  Created by 林锦超 on 2019/3/9.
//  Copyright © 2019 林锦超. All rights reserved.
//

#import "LJCViewController.h"
#import "LJCTableView.h"
#import "LJCTextView.h"

@interface LJCViewController ()
@property (nonatomic, strong) LJCTableView *tableView;
@property (nonatomic, strong) LJCTextView *logView;
@property (nonatomic, strong) UIButton *addButton;
@property (nonatomic, strong) UIButton *removeButton;
@end

@implementation LJCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.addButton];
    [self.view addSubview:self.removeButton];
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.logView];
}

#pragma mark - Getter
- (UIButton *)addButton
{
    if (!_addButton) {
        CGFloat width = CGRectGetWidth(self.view.bounds) / 2;
        _addButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 30, width - 20, 30)];
        [_addButton setTitle:@"AddLine" forState:UIControlStateNormal];
        [_addButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_addButton addTarget:self action:@selector(handleAddButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        _addButton.layer.borderColor = [UIColor blackColor].CGColor;
        _addButton.layer.borderWidth = 1;
    }
    return _addButton;
}

- (UIButton *)removeButton
{
    if (!_removeButton) {
        CGFloat width = CGRectGetWidth(self.view.bounds) / 2;
        _removeButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.addButton.frame) + 10, 30, width - 20, 30)];
        [_removeButton setTitle:@"RemoveLine" forState:UIControlStateNormal];
        [_removeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_removeButton addTarget:self action:@selector(handleRemoveButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        _removeButton.layer.borderColor = [UIColor blackColor].CGColor;
        _removeButton.layer.borderWidth = 1;
    }
    return _removeButton;
}

- (LJCTableView *)tableView
{
    if (!_tableView) {
        CGFloat yOffset = CGRectGetMaxY(self.removeButton.frame) + 10;
        _tableView = [[LJCTableView alloc] initWithFrame:CGRectMake(0, yOffset, CGRectGetWidth(self.view.bounds), CGRectGetMinY(self.logView.frame) - yOffset)];
        _tableView.backgroundColor = [UIColor whiteColor];
    }
    return _tableView;
}

- (LJCTextView *)logView
{
    if (!_logView) {
        CGFloat height = 150;
        _logView = [[LJCTextView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds) - height, CGRectGetWidth(self.view.bounds), height)];
        _logView.layer.borderColor = [UIColor blackColor].CGColor;
        _logView.layer.borderWidth = 1;
        _logView.backgroundColor = [UIColor lightGrayColor];
    }
    return _logView;
}

#pragma mark - Action
- (IBAction)handleAddButtonPressed:(id)sender
{
    // object相同对象即可
    [[LJCNotificationCenter defaultCenter] postNotificationName:LJCAddLineNotification object:@"123" userInfo:@{ @"data" : [self _randomString]}];
    
    [NSNotificationQueue defaultQueue];
}

- (IBAction)handleRemoveButtonPressed:(id)sender
{
    LJCNotification *notification = [[LJCNotification alloc] initWithName:LJCRemoveLineNotification object:@"remove" userInfo:@{ @"data" : @"nothing" }];
    NSLog(@"handleRemoveButtonPressed:%@", notification);
    
    [[LJCNotificationCenter defaultCenter] postNotification:notification];
//    [[LJCNotificationCenter defaultCenter] postNotificationName:LJCRemoveLineNotification object:nil];
    
    [self _archiverNotification:notification];
}

#pragma mark -
- (NSString *)_randomString
{
    return [NSString stringWithFormat:@"%d", arc4random_uniform(10000000)];
}
- (void)_archiverNotification:(LJCNotification *)note
{
    if (!note) {
        return;
    }
    NSError *error;
    // YES meas adopt NSSecureCoding protocol!!!!
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:note requiringSecureCoding:NO error:&error];
    if (!error) {
        NSLog(@"Archiver success:%@", data);
        
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingFromData:data error:&error];
        unarchiver.requiresSecureCoding = NO;
        id object = [unarchiver decodeObjectOfClass:[LJCNotification class] forKey:NSKeyedArchiveRootObjectKey];;
        
        // requiresSecureCoding = YES, default
//        id object = [NSKeyedUnarchiver unarchivedObjectOfClass:[LJCNotification class] fromData:data error:&error];
        
        if (!error) {
            NSLog(@"Unarchiver success:%@", object);
            if ([object isKindOfClass:[LJCNotification class]]) {
                NSLog(@"Notification:%@", (LJCNotification *)object);
            }
        }
        else {
            NSLog(@"error:%@", error);
        }
    }
    else {
        NSLog(@"error:%@", error);
    }
}

@end
