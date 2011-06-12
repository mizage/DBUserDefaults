//
//  DBUtils.h
//  DBUserDefaults
//
//  Created by Tyler Bunnell on 6/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DBUtils : NSObject{}

+ (BOOL)isDropboxAvailable;
+ (NSString*)dropboxPath;

@end
