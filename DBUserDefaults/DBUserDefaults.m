//
//  DBUserDefaults.m
//  DBUserDefaults
//
//  Created by Tyler Bunnell on 6/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

NSString* const DBUserDefaultsDidChangeNotification = 
@"DBUserDefaultsDidChangeNotification";

#import "DBUserDefaults.h"
#import "DBUtils.h"
#import "FileUtils.h"
#import "DBFileMonitor.h"

@interface DBUserDefaults (NSUserDefaultsPartialReplacementPrivate)
- (BOOL)synchronizeToPath:(NSString*)directory;
@end

@interface DBUserDefaults ()
- (void)preferencesFileDidChange:(NSNotification*)notification;
@end

#pragma mark - DBUserDefaults Methods

@implementation DBUserDefaults

// This method enables Dropbox sync and overwrites the settings on dropbox with
//  the local settings. TODO: change this behavior to prompt the user about
//  overwriting.
// We store the state of the Dropbox sync in NSUserDefaults to allow us to
//  not sync if we don't want to.
- (void)enableDropboxSync
{
  [self synchronizeToPath:[FileUtils dropboxPreferencesFilePath]];
  [[NSUserDefaults standardUserDefaults] setBool:YES 
                                          forKey:kDBDropboxSyncEnabledKey];
  [DBFileMonitor enableFileMonitoring];
  [[NSNotificationCenter defaultCenter] 
   addObserver:self 
   selector:@selector(disableDropboxSync)
   name:DBDropboxFileDidChangeNotification
   object:nil];
}

// This method disables Dropbox sync
- (void)disableDropboxSync
{
  [self synchronizeToPath:[FileUtils localPreferencesFilePath]];
  [[NSUserDefaults standardUserDefaults] setBool:NO 
                                          forKey:kDBDropboxSyncEnabledKey];
  [DBFileMonitor disableFileMonitoring];
  [[NSNotificationCenter defaultCenter] 
   removeObserver:self 
   name:DBDropboxFileDidChangeNotification 
   object:nil];
}

- (void)preferencesFileDidChange:(NSNotification*)notification
{
  //TODO: add conflict resolution
  [deadbolt_ lock];
  [defaults_ release];
  defaults_ = [[NSMutableDictionary alloc] 
               initWithContentsOfFile:[FileUtils dropboxPreferencesFilePath]];
  [deadbolt_ unlock];
}

@end


#pragma mark - NSUserDefaults (Partial) Replacement


// See the NSUserDefaults documentation for details about what these methods do

static DBUserDefaults* sharedInstance;

@implementation DBUserDefaults (NSUserDefaultsPartialReplacement)

+ (DBUserDefaults*)standardUserDefaults
{
  @synchronized(sharedInstance)
  {
    if(!sharedInstance)
      sharedInstance = [[self alloc] init];
  }  
  return sharedInstance;
}
+ (void)resetStandardUserDefaults
{
  [sharedInstance synchronize];
  [sharedInstance release], sharedInstance = nil;
}

- (id)init
{
  if((self = [super init]))
  {
    deadbolt_ = [[NSLock alloc] init];
    defaults_ = [[NSMutableDictionary alloc] init];
  }
  return self;
}
- (void)dealloc
{
  [deadbolt_ release];
  [defaults_ release];
}

- (id)objectForKey:(NSString*)defaultName
{
  id retval;
  
  [deadbolt_ lock];
  retval = [defaults_ objectForKey:defaultName];
  [deadbolt_ unlock];
  
  return retval;
}
- (void)setObject:(id)value forKey:(NSString*)defaultName
{
  [deadbolt_ lock];
  [defaults_ setObject:value forKey:defaultName];
  [deadbolt_ unlock];
}
- (void)removeObjectForKey:(NSString*)defaultName
{
  [deadbolt_ lock];
  [defaults_ removeObjectForKey:defaultName];
  [deadbolt_ unlock];
}

- (NSString*)stringForKey:(NSString*)defaultName
{
  return (NSString*)[self objectForKey:defaultName];
}
- (NSArray*)arrayForKey:(NSString*)defaultName
{
  return (NSArray*)[self objectForKey:defaultName];
}
- (NSDictionary*)dictionaryForKey:(NSString*)defaultName
{
  return (NSDictionary*)[self objectForKey:defaultName];
}
- (NSData*)dataForKey:(NSString*)defaultName
{
  return (NSData*)[self objectForKey:defaultName];
}
- (NSArray*)stringArrayForKey:(NSString*)defaultName
{
  return (NSArray*)[self objectForKey:defaultName];
}
- (NSInteger)integerForKey:(NSString*)defaultName
{
  NSNumber* retval = [self objectForKey:defaultName];
  return [retval integerValue];
}
- (float)floatForKey:(NSString*)defaultName
{
  NSNumber* retval = [self objectForKey:defaultName];
  return [retval floatValue];
}
- (double)doubleForKey:(NSString*)defaultName
{
  NSNumber* retval = [self objectForKey:defaultName];
  return [retval doubleValue];
}
- (BOOL)boolForKey:(NSString*)defaultName
{
  NSNumber* retval = [self objectForKey:defaultName];
  return [retval boolValue];
}
- (NSURL*)URLForKey:(NSString*)defaultName
{
  return (NSURL*)[self objectForKey:defaultName];
}

- (void)setInteger:(NSInteger)value forKey:(NSString*)defaultName
{
  NSNumber* objectValue = [NSNumber numberWithInteger:value];
  [self setObject:objectValue forKey:defaultName];
}
- (void)setFloat:(float)value forKey:(NSString*)defaultName
{
  NSNumber* objectValue = [NSNumber numberWithFloat:value];
  [self setObject:objectValue forKey:defaultName];
}
- (void)setDouble:(double)value forKey:(NSString*)defaultName
{
  NSNumber* objectValue = [NSNumber numberWithDouble:value];
  [self setObject:objectValue forKey:defaultName];
}
- (void)setBool:(BOOL)value forKey:(NSString*)defaultName
{
  NSNumber* objectValue = [NSNumber numberWithBool:value];
  [self setObject:objectValue forKey:defaultName];
}
- (void)setURL:(NSURL*)url forKey:(NSString*)defaultName
{
  [self setObject:url forKey:defaultName];
}

- (void)registerDefaults:(NSDictionary*)registrationDictionary
{
  NSMutableDictionary* merged = 
  [NSMutableDictionary dictionaryWithDictionary:registrationDictionary];
  
  [merged addEntriesFromDictionary:defaults_];
  
  [deadbolt_ lock];
  [defaults_ release];
  defaults_ = [[NSMutableDictionary alloc] initWithDictionary:merged];
  [deadbolt_ unlock];
}

- (NSDictionary*)dictionaryRepresentation
{
  return [NSDictionary dictionaryWithDictionary:defaults_];
}

- (BOOL)synchronize
{
  NSString* preferencesFilePath = [FileUtils preferencesFilePath];
  return [self synchronizeToPath:preferencesFilePath];
}

@end


#pragma mark - NSUserDefaults (Partial) Replacement Private Methods


@implementation DBUserDefaults (NSUserDefaultsPartialReplacementPrivate)

- (BOOL)synchronizeToPath:(NSString*)directory
{  
  return [defaults_ writeToFile:directory atomically:YES];  
}

@end
