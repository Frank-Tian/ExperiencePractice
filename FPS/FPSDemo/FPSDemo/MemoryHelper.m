//
//  MemoryHelper.m
//  MaxMemoryBudget
//
//  Created by Tian on 2021/6/5.
//

#import "MemoryHelper.h"
#import <sys/types.h>
#import <sys/sysctl.h>
#import <mach/mach.h>

@implementation MemoryHelper

// 获取本机内存（单位：MB）
+ (double)getTotalMemorySize
{
    return [NSProcessInfo processInfo].physicalMemory / 1024.0 / 1024.0;
}

// 获取当前任务所占用的内存（单位：MB）
+ (double)currentAppUsedMemory
{
    int64_t memoryUsageInByte = 0;
    task_vm_info_data_t vmInfo;
    mach_msg_type_number_t count = TASK_VM_INFO_COUNT;
    kern_return_t kernelReturn = task_info(mach_task_self(), TASK_VM_INFO, (task_info_t) &vmInfo, &count);
    if(kernelReturn == KERN_SUCCESS) {
        memoryUsageInByte = (int64_t) vmInfo.phys_footprint;
        //NSLog(@"Memory in use (in bytes): %lld", memoryUsageInByte);
    } else {
        NSLog(@"Error with task_info(): %s", mach_error_string(kernelReturn));
    }
    
    return memoryUsageInByte  / 1024.0 / 1024.0;
}

// 获取当前设备可用内存(单位：MB）
+ (double)availableMemory
{
    vm_statistics_data_t vmStats;
    mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
    kern_return_t kernReturn = host_statistics(mach_host_self(),
                                               HOST_VM_INFO,
                                               (host_info_t)&vmStats,
                                               &infoCount);
    
    if (kernReturn != KERN_SUCCESS) {
        return NSNotFound;
    }
    
    return ((vm_page_size *vmStats.free_count) / 1024.0) / 1024.0;
}

@end
