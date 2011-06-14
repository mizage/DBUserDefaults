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


#import "DBFileMonitor.h"
#import "FileUtils.h"

static FSEventStreamRef DBPreferencesFileMonitor;  
static NSDate* previousModificationDate;

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
  
  NSDictionary* attributes = [[NSFileManager defaultManager] 
                              attributesOfItemAtPath:
                              [FileUtils preferencesFilePath] 
                              error:nil];
  
  // Get the modification date of our preferences file
  NSDate* modificationDate = [attributes objectForKey:NSFileModificationDate];
  
  // If the modification dates do not match, we need to sync
  if(![modificationDate isEqualToDate:previousModificationDate])
  {
    [[NSNotificationCenter defaultCenter] 
     postNotificationName:DBDropboxFileDidChangeNotification object:nil];
    [previousModificationDate release];
    previousModificationDate = [modificationDate retain];
  }  
}


+ (void)enableFileMonitoring
{
  if(![[NSUserDefaults standardUserDefaults] 
       boolForKey:kDBDropboxSyncEnabledKey] || 
     DBPreferencesFileMonitor)
    return;
  
  NSDictionary* attributes = [[NSFileManager defaultManager] 
                              attributesOfItemAtPath:
                              [FileUtils preferencesFilePath] 
                              error:nil];
  
  previousModificationDate = [[attributes objectForKey:NSFileModificationDate] 
                              retain];
  
  FSEventStreamContext context = {0};
  context.info = self;
  
  NSString* preferencesFilePath = [FileUtils preferencesDirectoryPath];
  
  NSArray* pathsToWatch = [NSArray arrayWithObject:
                           preferencesFilePath];
  
  DBPreferencesFileMonitor = 
  FSEventStreamCreate(NULL,
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
