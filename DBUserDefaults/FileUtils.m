//
//  FileUtils.m
//  DBUserDefaults
//
//  Created by Tyler Bunnell on 6/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FileUtils.h"
#import "DBUtils.h"

NSString* const DBDropboxFileDidChangeNotification = 
                  @"DBDropboxFileDidChangeNotification";

@implementation FileUtils

// This method checks to see if the preferences file exists in Dropbox
+ (BOOL)dropboxPreferencesExist
{
  return [[NSFileManager defaultManager] 
          fileExistsAtPath:[FileUtils dropboxPreferencesFilePath]];
}

// This method is a convenience method to return the file path of the
//  preferences file based on the current syncing state
+ (NSString*)preferencesFilePath
{
  if([[NSUserDefaults standardUserDefaults] 
      boolForKey:kDBDropboxSyncEnabledKey])
    return [FileUtils dropboxPreferencesFilePath];
  else
    return [FileUtils localPreferencesFilePath];
}

// This method returns the path to the preferences file on Dropbox
+ (NSString*)dropboxPreferencesFilePath
{
  if(![DBUtils isDropboxAvailable])
    return nil;
  
  return [NSString stringWithFormat:@"%@/Preferences/%@DB.plist",
          [DBUtils dropboxPath],[[NSBundle mainBundle] bundleIdentifier]];
}

// This method returns the path to the preferences file on the local system
+ (NSString*)localPreferencesFilePath
{
  return [NSString stringWithFormat:@"%@/%@.plist",
          [FileUtils localPath],[[NSBundle mainBundle] bundleIdentifier]];
}

// This method returns a tilde expanded local path to the Preferences directory
+ (NSString*)localPath
{
  return [@"~/Preferences" stringByExpandingTildeInPath];
}

@end
