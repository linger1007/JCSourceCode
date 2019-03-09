//
//  LJCTextView.m
//  LJCNotificationCenter
//
//  Created by 林锦超 on 2019/3/9.
//  Copyright © 2019 林锦超. All rights reserved.
//

#import "LJCTextView.h"

@interface LJCTextView()
@property (nonatomic, strong) NSDateFormatter *formatter;
@end
@implementation LJCTextView

- (void)dealloc
{
    [[LJCNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _formatter = [[NSDateFormatter alloc] init];
        _formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        
        [[LJCNotificationCenter defaultCenter] addObserver:self selector:@selector(ljcAddLineNotification:) name:LJCAddLineNotification object:nil];
        [[LJCNotificationCenter defaultCenter] addObserver:self selector:@selector(ljcRemoveLineNotification:) name:LJCRemoveLineNotification object:nil];
    }
    return self;
}

#pragma mark -
- (void)ljcAddLineNotification:(LJCNotification *)notification
{
    NSString *data = notification.userInfo[@"data"] ? notification.userInfo[@"data"] : @"";
    self.text = [self.text stringByAppendingString:[NSString stringWithFormat:@"%@ 添加了一条数据：%@\n", [self.formatter stringFromDate:[NSDate date]], data]];
    [self scrollRangeToVisible:NSMakeRange(self.text.length, 1)];
}

- (void)ljcRemoveLineNotification:(LJCNotification *)notification
{
    self.text = [self.text stringByAppendingString:[NSString stringWithFormat:@"%@ 删除了一条数据\n", [self.formatter stringFromDate:[NSDate date]]]];
    
    [self _tryClear];
}

- (void)_tryClear
{
    if (self.text.length > 1024 * 20) { //20kb
        self.text = [NSString stringWithFormat:@"%@ clear...\n", [self.formatter stringFromDate:[NSDate date]]];
    }
}

@end
