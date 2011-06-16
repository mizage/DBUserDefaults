//  License Agreement for Source Code provided by Mizage LLC
//
//  This software is supplied to you by Mizage LLC in consideration of your
//  agreement to the following terms, and your use, installation, modification
//  or redistribution of this software constitutes acceptance of these terms. If
//  you do not agree with these terms, please do not use, install, modify or
//  redistribute this software.
//
//  In consideration of your agreement to abide by the following terms, and
//  subject to these terms, Mizage LLC grants you a personal, non-exclusive
//  license, to use, reproduce, modify and redistribute the software, with or
//  without modifications, in source and/or binary forms; provided that if you
//  redistribute the software in its entirety and without modifications, you
//  must retain this notice and the following text and disclaimers in all such
//  redistributions of the software, and that in all cases attribution of Mizage
//  LLC as the original author of the source code shall be included in all such
//  resulting software products or distributions.  Neither the name, trademarks,
//  service marks or logos of Mizage LLC may be used to endorse or promote
//  products derived from the software without specific prior written permission
//  from Mizage LLC. Except as expressly stated in this notice, no other rights
//  or licenses, express or implied, are granted by Mizage LLC herein, including
//  but not limited to any patent rights that may be infringed by your
//  derivative works or by other works in which the software may be
//  incorporated.
//
//  The software is provided by Mizage LLC on an "AS IS" basis. MIZAGE LLC MAKES
//  NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED
//  WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR
//  PURPOSE, REGARDING THE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN
//  COMBINATION WITH YOUR PRODUCTS.
//
//  IN NO EVENT SHALL MIZAGE LLC BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
//  OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
//  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
//  INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION
//  AND/OR DISTRIBUTION OF THE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY
//  OF CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE,
//  EVEN IF MIZAGE LLC HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

NSString* const DBUserDefaultsDidChangeNotification = 
@"DBUserDefaultsDidChangeNotification";
NSString* const DBUserDefaultsDidSyncNotification =
@"DBUserDefaultsDidSyncNotification";

#import "DBUserDefaults.h"
#import "DBUtils.h"
#import "DBFileUtils.h"
#import "DBFileMonitor.h"
#import "DBSyncPrompt.h"
#import "DBStatus.h"

@interface DBUserDefaults ()
- (void)enableDropboxSync;
- (void)disableDropboxSync;
- (void)syncFromDropbox;
- (void)preferencesFileDidChange:(NSNotification*)notification;
@end

#pragma mark - DBUserDefaults Methods

@implementation DBUserDefaults

- (BOOL)isDropboxSyncEnabled
{
  return [DBStatus isDropboxSyncEnabled];
}

- (void)setDropboxSyncEnabled:(BOOL)enabled
{
  if(enabled)
    [self enableDropboxSync];
  else
    [self disableDropboxSync];
}

// Enables Dropbox sync and overwrites the settings on dropbox with the local
//  settings.
- (void)enableDropboxSync
{
  if([DBStatus isDropboxSyncEnabled])
    return;
  
  if([DBFileUtils dropboxPreferencesExist])
  {
    DBSyncPrompt* prompt = [[DBSyncPrompt alloc] init];
    
    [prompt setDelegate:self];
    [prompt displayPrompt];    
    [prompt release];
  }
  else
  {
    [DBStatus setDropboxSyncEnabled:YES];
    
    [self synchronize];
    
    [DBFileMonitor enableFileMonitoring];
    [[NSNotificationCenter defaultCenter] 
     addObserver:self 
     selector:@selector(preferencesFileDidChange:)
     name:DBDropboxFileDidChangeNotification
     object:nil];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:DBUserDefaultsDidSyncNotification 
     object:nil];
  }
}

// Delegate callback from the DBSyncPrompt window. Either overwites the local
//  data with the data from dropbox, or overwrites the data in Dropbox with
//  the local data. Also enables file monitoring to listen for changes to the
//  preferences file.
// Posts a DBUserDefaultsDidSyncNotification to inform the host application to
//  reload all preferences.
- (void)syncPromptDidSelectOption:(DBSyncPromptOption)option
{
  if (option == DBSyncPromptOptionLocal)
  {
    [self syncFromDropbox];
  }  
  
  [DBStatus setDropboxSyncEnabled:YES];
  
  [self synchronize];
  
  [DBFileMonitor enableFileMonitoring];
  [[NSNotificationCenter defaultCenter] 
   addObserver:self 
   selector:@selector(preferencesFileDidChange:)
   name:DBDropboxFileDidChangeNotification
   object:nil];
  [[NSNotificationCenter defaultCenter]
   postNotificationName:DBUserDefaultsDidSyncNotification 
   object:nil];
}

// Replaces the in-memory defaults dictionary with the contents of the Dropbox
//  file.
- (void)syncFromDropbox
{
  [deadbolt_ lock];
  [defaults_ release];
  defaults_ = [[NSMutableDictionary alloc] 
               initWithContentsOfFile:[DBFileUtils dropboxPreferencesFilePath]];
  [deadbolt_ unlock];
}

// Disables Dropbox sync. Writes the in-memory dictionary to the local file path
//  and disables file monitoring of the Dropbox preferences file.
- (void)disableDropboxSync
{
  if(![DBStatus isDropboxSyncEnabled])
    return;
  
  [DBStatus setDropboxSyncEnabled:NO];
  [self synchronize];
  
  [DBFileMonitor disableFileMonitoring];
  [[NSNotificationCenter defaultCenter] 
   removeObserver:self 
   name:DBDropboxFileDidChangeNotification 
   object:nil];
}

// Notification handler for when the preferences file changes. Reloads 
//  in-memory dictionary from Dropbox and posts a
//  DBUserDefaultsDidSyncNotification.
- (void)preferencesFileDidChange:(NSNotification*)notification
{
  [self syncFromDropbox];
  [[NSNotificationCenter defaultCenter]
   postNotificationName:DBUserDefaultsDidSyncNotification 
   object:nil];
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
    
    if([DBFileUtils preferencesExist])
    {
      
      defaults_ = [[NSMutableDictionary dictionaryWithContentsOfFile:
                    [DBFileUtils preferencesFilePath]] retain];
      if([DBStatus isDropboxSyncEnabled])
        [DBFileMonitor enableFileMonitoring];
    }
    else
    { 
      defaults_ = [[NSMutableDictionary alloc] init];
    }
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
  
  [[NSNotificationCenter defaultCenter]
   postNotificationName:DBUserDefaultsDidChangeNotification 
   object:nil];
}
- (void)removeObjectForKey:(NSString*)defaultName
{
  [deadbolt_ lock];
  [defaults_ removeObjectForKey:defaultName];
  [deadbolt_ unlock];
  
  [[NSNotificationCenter defaultCenter]
   postNotificationName:DBUserDefaultsDidChangeNotification 
   object:nil];
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
  
  [[NSNotificationCenter defaultCenter] 
   postNotificationName:DBUserDefaultsDidChangeNotification object:nil];
}

- (NSDictionary*)dictionaryRepresentation
{
  return [NSDictionary dictionaryWithDictionary:defaults_];
}

- (BOOL)synchronize
{  
  if(![[NSFileManager defaultManager] 
       fileExistsAtPath:[DBFileUtils preferencesDirectoryPath]])
  {
    [[NSFileManager defaultManager] 
     createDirectoryAtPath:[DBFileUtils preferencesDirectoryPath] 
     withIntermediateDirectories:YES 
     attributes:nil 
     error:nil];
  }
  
  return [defaults_ writeToFile:[DBFileUtils preferencesFilePath] atomically:YES];
}

@end
