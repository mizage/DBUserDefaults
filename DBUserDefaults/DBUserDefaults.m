//
//  DBUserDefaults.m
//  DBUserDefaults
//
//  Created by Tyler Bunnell on 6/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#define kDropboxSyncEnabledKey @"DBDropboxSyncEnabled"

#import "DBUserDefaults.h"
#import "DBUtils.h"

@interface DBUserDefaults ()
- (BOOL)dropboxPreferencesExist;
- (NSString*)preferencesFilePath;
- (NSString*)dropboxPreferencesFilePath;
- (NSString*)localPreferencesFilePath;
- (NSString*)localPath;
@end

@interface DBUserDefaults (NSUserDefaultsPartialReplacementPrivate)
- (BOOL)synchronizeToPath:(NSString*)directory;
@end

#pragma mark - DBUserDefaults Methods

@implementation DBUserDefaults

- (void)enableDropboxSync
{
  [self synchronizeToPath:[self dropboxPreferencesFilePath]];
  [self setBool:YES forKey:kDropboxSyncEnabledKey];
}

- (void)disableDropboxSync
{
  [self synchronizeToPath:[self localPreferencesFilePath]];
  [self setBool:NO forKey:kDropboxSyncEnabledKey];
}

- (BOOL)dropboxPreferencesExist
{
  return [[NSFileManager defaultManager] 
          fileExistsAtPath:[self dropboxPreferencesFilePath]];
}
- (NSString*)preferencesFilePath
{
  if([self boolForKey:kDropboxSyncEnabledKey])
    return [self dropboxPreferencesFilePath];
  else
    return [self localPreferencesFilePath];
}
- (NSString*)dropboxPreferencesFilePath
{
  if(![DBUtils isDropboxAvailable])
    return nil;
  
  return [NSString stringWithFormat:@"%@/Preferences/%@.plist",
          [DBUtils dropboxPath],[[NSBundle mainBundle] bundleIdentifier]];
}
- (NSString*)localPreferencesFilePath
{
  return [NSString stringWithFormat:@"%@/%@.plist",
          [self localPath],[[NSBundle mainBundle] bundleIdentifier]];
}

- (NSString*)localPath
{
  return [@"~/Preferences" stringByExpandingTildeInPath];
}

@end


#pragma mark - NSUserDefaults (Partial) Replacement


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
    deadbolt = [[NSLock alloc] init];
    defaults = [[NSMutableDictionary alloc] init];
  }
  return self;
}
- (void)dealloc
{
  [deadbolt release];
  [defaults release];
}

- (id)objectForKey:(NSString*)defaultName
{
  id retval;
  
  [deadbolt lock];
  retval = [defaults objectForKey:defaultName];
  [deadbolt unlock];
  
  return retval;
}
- (void)setObject:(id)value forKey:(NSString*)defaultName
{
  [deadbolt lock];
  [defaults setObject:value forKey:defaultName];
  [deadbolt unlock];
}
- (void)removeObjectForKey:(NSString*)defaultName
{
  [deadbolt lock];
  [defaults removeObjectForKey:defaultName];
  [deadbolt unlock];
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
  NSMutableDictionary* merged = [NSMutableDictionary dictionaryWithDictionary:registrationDictionary];
  
  [merged addEntriesFromDictionary:defaults];
  
  [deadbolt lock];
  [defaults release];
  defaults = [[NSMutableDictionary alloc] initWithDictionary:merged];
  [deadbolt unlock];
}

- (NSDictionary*)dictionaryRepresentation
{
  return [NSDictionary dictionaryWithDictionary:defaults];
}

- (BOOL)synchronize
{
  NSString* preferencesFilePath = [self preferencesFilePath];
  return [self synchronizeToPath:preferencesFilePath];
}

@end


#pragma mark - NSUserDefaults (Partial) Replacement Private Methods


@implementation DBUserDefaults (NSUserDefaultsPartialReplacementPrivate)

- (BOOL)synchronizeToPath:(NSString*)directory
{  
  return [defaults writeToFile:directory atomically:YES];  
}

@end
