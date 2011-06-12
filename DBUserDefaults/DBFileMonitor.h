//
//  DBFileMonitor.h
//  DBUserDefaults
//
//  Created by Tyler Bunnell on 6/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreServices/CoreServices.h>

// This class only uses class methods, so no instance variables are needed.
@interface DBFileMonitor : NSObject{}
+ (void)enableFileMonitoring;
+ (void)disableFileMonitoring;
@end
