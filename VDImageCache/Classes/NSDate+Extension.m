//
//  NSDate+Extension.m
//
//  Created by Vu.Doan on 11/13/17.
//  Copyright © 2017 Vu.Doan. All rights reserved.
//

#import "NSDate+Extension.h"

@implementation NSDate(Compare)

+ (NSInteger)daysBetweenDate:(NSDate *)fromDateTime andDate:(NSDate *)toDateTime {
    
    NSDate* fromDate;
    NSDate* toDate;
    
    NSCalendar* calendar = [NSCalendar currentCalendar];
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&fromDate interval:NULL forDate:fromDateTime];
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&toDate interval:NULL forDate:toDateTime];
    NSDateComponents* difference = [calendar components:NSCalendarUnitDay fromDate:fromDate toDate:toDate options:0];
    
    return [difference day];
}

@end
