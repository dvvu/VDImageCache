//
//  NSString+Extension.h
//
//  Created by Vu.Doan on 11/13/17.
//  Copyright © 2017 Vu.Doan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString(ContactPicker)

/**
 Remove acent of string

 @return ANSCI string
 */
- (NSString *)toANSCI;

/**
 Get first character represent string in alphabet

 @return alphabet letter
 */
- (NSString *)getFirstChar;

@end
