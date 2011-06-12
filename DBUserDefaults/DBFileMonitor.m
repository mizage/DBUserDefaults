//
//  DBFileMonitor.m
//  DBUserDefaults
//
//  Created by Tyler Bunnell on 6/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DBFileMonitor.h"
#import "FileUtils.h"

static FSEventStreamRef DBPreferencesFileMonitor;  

// DBFileMonitor is a class that provides class methods used to enable file
//  monitoring on the dropbox preferences file.
@implementation DBFileMonitor


// This function is a callback that informs us of a change to our preferences
//  file on dropbox so we can update our in-memory preferences. If a change
//  is detected, a notification is posted.
void preferencesFileChanged(
                            ConstFSEventStreamRef streamRef,
                            void *clientCallBackInfo,
                            size_t numEvents,
                            void *eventPaths,
                            const FSEventStreamEventFlags eventFlags[],
                            const FSEventStreamEventId eventIds[])
{
  [[NSNotificationCenter defaultCenter] 
   postNotificationName:DBDropboxFileDidChangeNotification object:nil];
}


+ (void)enableFileMonitoring
{
  if(![[NSUserDefaults standardUserDefaults] 
       boolForKey:kDBDropboxSyncEnabledKey] || 
     DBPreferencesFileMonitor)
    return;
  
  FSEventStreamContext context = {0};
  context.info = self;
  
  NSArray* pathsToWatch = [NSArray arrayWithObject:
                           [FileUtils preferencesFilePath]];
  DBPreferencesFileMonitor = FSEventStreamCreate(NULL,
                                     preferencesFileChanged,
                                     &context,
                                     (CFArrayRef)pathsToWatch, 
                                     kFSEventStreamEventIdSinceNow,
                                     1,
                                     kFSEventStreamCreateFlagUseCFTypes | 
                                     kFSEventStreamCreateFlagIgnoreSelf);
  FSEventStreamScheduleWithRunLoop(DBPreferencesFileMonitor, 
                                   CFRunLoopGetCurrent(), 
                                   kCFRunLoopDefaultMode);
  FSEventStreamStart(DBPreferencesFileMonitor);
}
+ (void)disableFileMonitoring
{
  if(!DBPreferencesFileMonitor)
    return;
  
  FSEventStreamStop(DBPreferencesFileMonitor);
  FSEventStreamUnscheduleFromRunLoop(DBPreferencesFileMonitor, 
                                     CFRunLoopGetCurrent(), 
                                     kCFRunLoopDefaultMode);
  FSEventStreamInvalidate(DBPreferencesFileMonitor);
  FSEventStreamRelease(DBPreferencesFileMonitor);
  DBPreferencesFileMonitor = NULL;  
}

@end
