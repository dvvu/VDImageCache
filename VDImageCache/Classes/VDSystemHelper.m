//
//  VDSystemHelper.m
//  VDImageCache
//
//  Created by Vu.Doan on 11/13/17.
//  Copyright © 2017 Vu.Doan. All rights reserved.
//

#import "VDSystemHelper.h"
#import <mach/host_info.h>
#import <mach/mach_host.h>
#import <mach/task_info.h>
#import <mach/task.h>

@implementation VDSystemHelper

+ (unsigned long)getFreeMemory {
    
    mach_port_t host_port;
    mach_msg_type_number_t host_size;
    vm_size_t pagesize;
    host_port = mach_host_self();
    host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    host_page_size(host_port, &pagesize);
    vm_statistics_data_t vm_stat;
  
    if (host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size) != KERN_SUCCESS) {
    
        NSLog(@"Failed to fetch vm statistics");
        return 0;
    }
    
    return vm_stat.free_count * pagesize;
}

@end
