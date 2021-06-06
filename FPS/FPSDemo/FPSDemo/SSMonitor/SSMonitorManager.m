//
//  SSMonitorManager.m
//  StarStar
//
//  Created by tian on 2019/5/20.
//  Copyright © 2019 tian. All rights reserved.
//

#import "SSMonitorManager.h"
#import "SSDeviceMonitor.h"
#import "MemoryHelper.h"

/// 帧率采样个数
static NSInteger kAverageFPSSamplingCount = 60;

@interface SSMonitorManager ()<SSDeviceMonitorDelegate>

@property (nonatomic, assign) BOOL infoDisplay;
@property (nonatomic, strong) SSMonitorView *floatWindow;

@property (nonatomic, strong) NSMutableArray *fpsCache;/// 记录一定量的帧率值
@end

@implementation SSMonitorManager

+ (instancetype)sharedManager
{
    static SSMonitorManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[SSMonitorManager alloc] init];
        manager.infoDisplay = NO;
        manager.fpsCache = [NSMutableArray array];
    });
    return manager;
}

- (void)starMonitor
{
//    return;
    [[SSDeviceMonitor sharedInstance] startMonitor];
    
//#ifndef __OPTIMIZE__
    [SSDeviceMonitor sharedInstance].delegate = self;
    [self toggleMonitorWindow:YES];
//#endif
}

- (void)toggleMonitorView
{
    [self toggleMonitorWindow:!self.infoDisplay];
}

- (void)toggleMonitorWindow:(BOOL)show
{
    if (show) {
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        [window addSubview:self.floatWindow];
        CGFloat width = 150;
        CGFloat height = 250/2;
        CGPoint point = CGPointMake([UIScreen mainScreen].bounds.size.width - width/2, 100 + height/2);
        CGRect frame = CGRectMake(0, 0, width, height);
        self.floatWindow.frame = frame;
        self.floatWindow.center = point;
        [self.floatWindow.closeBtn addTarget:self action:@selector(closeAction) forControlEvents:UIControlEventTouchUpInside];
    } else {
        [self.floatWindow removeFromSuperview];
    }
}

- (SSMonitorView *)floatWindow
{
    if (!_floatWindow) {
        _floatWindow = [[SSMonitorView alloc] init];
    }
    return _floatWindow;
}

- (void)closeAction
{
    [self toggleMonitorWindow:NO];
}

#pragma mark - SSDeviceMonitorDelegate

- (void)deviceInformationDidChanged:(SSDeviceMonitor *)monitor
{
    SSMonitorInfoModel *monitorInfo = [[SSMonitorInfoModel alloc] init];
    
    monitorInfo.cpu                 = monitor.cpu;
    monitorInfo.appCpu              = monitor.appCpu;
    monitorInfo.threadCount         = monitor.threadCount;
    monitorInfo.memoryUsed          = [MemoryHelper currentAppUsedMemory];
    monitorInfo.totalMemory         = [MemoryHelper getTotalMemorySize];
    monitorInfo.availableMemory     = [MemoryHelper availableMemory];
    monitorInfo.batteryLevel        = monitor.batteryLevel;
    monitorInfo.fps                 = monitor.fps;
    monitorInfo.avgFps              = [self calculateAverageFPS:monitor.fps];
    
// #ifndef __OPTIMIZE__
    [self.floatWindow updateMonitorInfo:monitorInfo];
//#endif
}

#pragma mark - Private

/**
 计算平均帧率的策略
 1、根据 kAverageFPSSamplingCount 数量进行采样，倒序最大取这么多进行均值计算
 2、多于 kAverageFPSSamplingCount 的数量会被移除
 */
- (NSInteger)calculateAverageFPS:(NSInteger)fps
{
    [self.fpsCache addObject:@(fps)];
    if (self.fpsCache.count > kAverageFPSSamplingCount) {
        NSInteger len = self.fpsCache.count - kAverageFPSSamplingCount;
        NSRange range = NSMakeRange(0, len);
        [self.fpsCache removeObjectsInRange:range];
    }
    
    NSInteger count = self.fpsCache.count;
    CGFloat totalFPS = 0;
    for (int i = 0; i < count; i++) {
        totalFPS += [[self.fpsCache objectAtIndex:i] integerValue];
    }
    NSInteger avgFPS = (NSInteger)round(totalFPS / count);
    return avgFPS;
}
@end
