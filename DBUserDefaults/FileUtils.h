//
//  FileUtils.h
//  DBUserDefaults
//
//  Created by Tyler Bunnell on 6/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kDBDropboxSyncEnabledKey @"DBDropboxSyncEnabled"

extern NSString* const DBDropboxFileDidChangeNotification;

@interface FileUtils : NSObject {}

// This method checks to see if the preferences file exists in Dropbox
+ (BOOL)dropboxPreferencesExist;
+ (NSString*)preferencesFilePath;
+ (NSString*)dropboxPreferencesFilePath;
+ (NSString*)localPreferencesFilePath;
+ (NSString*)localPath;

@end
