//
//  SSDeviceMonitor.m
//  StarStar
//
//  Created by tian on 2019/5/20.
//  Copyright © 2019 tian. All rights reserved.
//

#import "SSDeviceMonitor.h"
#import <stdlib.h>
#import <mach/mach.h>
//#import <sys/sysctl.h>
#import <objc/runtime.h>

@interface SSDeviceMonitor()

@property (nonatomic, assign) CGFloat cpu;
@property (nonatomic, assign) CGFloat appCpu;
@property (nonatomic, assign) NSUInteger threadCount;
@property (nonatomic, assign) CGFloat batteryLevel;
@property (nonatomic, copy  ) NSString *batteryState;

@property (nonatomic, strong) CADisplayLink *fpsLink;
@property (nonatomic, assign) NSTimeInterval lastTime;
@property (nonatomic, assign) NSUInteger count;
@property (nonatomic, assign) NSInteger fps;
@end

@implementation SSDeviceMonitor

- (instancetype)init
{
    self = [super init];
    if (self) {
        _fpsLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkTick:)];
        [_fpsLink setPaused:YES];
        [_fpsLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
    return self;
}

+ (instancetype)sharedInstance {
    static SSDeviceMonitor *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SSDeviceMonitor alloc] init];
    });
    return instance;
}

- (void)fourceRefreshDeviceInfo
{
    [[SSDeviceMonitor sharedInstance] cpuUsage];
    [[SSDeviceMonitor sharedInstance] batteryUsage];
}

#pragma mark - FPS

- (void)displayLinkTick:(CADisplayLink *)link
{
    if (self.lastTime == 0) {
        self.lastTime = link.timestamp;
        return;
    }
    
    self.count++;
    NSTimeInterval interval = link.timestamp - self.lastTime;
    if (interval < 1) return;
    self.lastTime = link.timestamp;
    float fps = self.count / interval;
    self.count = 0;
    
    NSInteger fpsInt = (int)round(fps);
    self.fps = fpsInt;
    
    // 刷新信息，进行回调
    [self fourceRefreshDeviceInfo];

    if ([self.delegate respondsToSelector:@selector(deviceInformationDidChanged:)]) {
        [self.delegate deviceInformationDidChanged:self];
    }
}

- (void)startMonitor
{
    [self.fpsLink setPaused:NO];
}

- (void)stopMonitor
{
    [self.fpsLink setPaused:YES];
}
#pragma mark - CPU

// https://www.cnblogs.com/mobilefeng/p/4977783.html
- (void)cpuUsage {
    kern_return_t kr;
    task_info_data_t tinfo;
    mach_msg_type_number_t task_info_count;
    
    task_info_count = TASK_INFO_MAX;
    kr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)tinfo, &task_info_count);
    if (kr != KERN_SUCCESS) {
        return;
    }
    
    task_basic_info_t      basic_info;
    thread_array_t         thread_list;
    mach_msg_type_number_t thread_count;
    
    thread_info_data_t     thinfo;
    mach_msg_type_number_t thread_info_count;
    
    thread_basic_info_t basic_info_th;
    uint32_t stat_thread = 0; // Mach threads
    
    basic_info = (task_basic_info_t)tinfo;
    
    // get threads in the task
    kr = task_threads(mach_task_self(), &thread_list, &thread_count);
    if (kr != KERN_SUCCESS) {
        return;
    }
    if (thread_count > 0)
        stat_thread += thread_count;
    
    long tot_sec = 0;
    long tot_usec = 0;
    float tot_cpu = 0;
    int j;
    
    for (j = 0; j < thread_count; j++)
    {
        thread_info_count = THREAD_INFO_MAX;
        kr = thread_info(thread_list[j], THREAD_BASIC_INFO,
                         (thread_info_t)thinfo, &thread_info_count);
        if (kr != KERN_SUCCESS) {
            return;
        }
        
        
        basic_info_th = (thread_basic_info_t)thinfo;
        
        if (!(basic_info_th->flags & TH_FLAGS_IDLE)) {
            tot_sec = tot_sec + basic_info_th->user_time.seconds + basic_info_th->system_time.seconds;
            tot_usec = tot_usec + basic_info_th->system_time.microseconds + basic_info_th->system_time.microseconds;
            tot_cpu = tot_cpu + basic_info_th->cpu_usage / (float)TH_USAGE_SCALE * 100.0;
        }
        
    } // for each thread
    
    kr = vm_deallocate(mach_task_self(), (vm_offset_t)thread_list, thread_count * sizeof(thread_t));
    assert(kr == KERN_SUCCESS);
    
    // CPU ALL
    CGFloat cpuUsageInIphone = [self appCpuUsage];
    
    self.cpu = tot_cpu;
    self.appCpu = isnan(cpuUsageInIphone) ? -1 :cpuUsageInIphone;
    self.threadCount = thread_count;
    //NSLog(@"---IKMonitor--- CPU: %.2f, CPU-ALL: %.2f", tot_cpu, cpuUsageInIphone);
    //NSLog(@"---IKMonitor--- ThreadCount: %d", thread_count);
}

- (CGFloat)appCpuUsage {
    kern_return_t kr;
    mach_msg_type_number_t count;
    static host_cpu_load_info_data_t previous_info = {0, 0, 0, 0};
    host_cpu_load_info_data_t info;
    
    count = HOST_CPU_LOAD_INFO_COUNT;
    
    kr = host_statistics(mach_host_self(), HOST_CPU_LOAD_INFO, (host_info_t)&info, &count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }
    
    natural_t user   = info.cpu_ticks[CPU_STATE_USER] - previous_info.cpu_ticks[CPU_STATE_USER];
    natural_t nice   = info.cpu_ticks[CPU_STATE_NICE] - previous_info.cpu_ticks[CPU_STATE_NICE];
    natural_t system = info.cpu_ticks[CPU_STATE_SYSTEM] - previous_info.cpu_ticks[CPU_STATE_SYSTEM];
    natural_t idle   = info.cpu_ticks[CPU_STATE_IDLE] - previous_info.cpu_ticks[CPU_STATE_IDLE];
    natural_t total  = user + nice + system + idle;
    previous_info    = info;
    
    return (user + nice + system) * 100.0 / total;
}

#pragma mark - Battery

- (void)batteryUsage {
    // Battery
    [UIDevice currentDevice].batteryMonitoringEnabled = YES;
    float batteryLevel = [UIDevice currentDevice].batteryLevel * 100.0;
    UIDeviceBatteryState batteryState = [UIDevice currentDevice].batteryState;
    NSString *batteryStateStr = nil;
    switch (batteryState) {
        case UIDeviceBatteryStateUnknown:
            batteryStateStr = @"Unknown";
            break;
        case UIDeviceBatteryStateUnplugged:
            batteryStateStr = @"Unplugged";
            break;
        case UIDeviceBatteryStateCharging:
            batteryStateStr = @"Charging";
            break;
        case UIDeviceBatteryStateFull:
            batteryStateStr = @"Full";
            break;
        default:
            break;
    }
    
    if (@available(iOS 9.0, *)) {
        if ([[NSProcessInfo processInfo] isLowPowerModeEnabled]) {
            batteryStateStr = [batteryStateStr stringByAppendingString:@"-LowPowerModeEnabled"];
        }
    }
    self.batteryLevel = batteryLevel;
    self.batteryState = batteryStateStr;
    //NSLog(@"---IKMonitor--- BatteryLevel: %.2f, BatteryState: %@", batteryLevel, batteryStateStr);
}

- (void)dealloc
{
    [_fpsLink setPaused:YES];
    [_fpsLink removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}
@end
