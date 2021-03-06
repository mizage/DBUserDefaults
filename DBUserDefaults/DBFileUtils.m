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


#import "DBFileUtils.h"
#import "DBUtils.h"
#import "DBStatus.h"

NSString* const DBDropboxFileDidChangeNotification = 
                  @"DBDropboxFileDidChangeNotification";

@interface DBFileUtils ()
+ (NSString*)localPreferencesDirectoryPath;
+ (NSString*)dropboxPreferencesDirectoryPath;
@end

@implementation DBFileUtils

// A convenience function to check if the preferences file exists base on
//  the current syncing state
+ (BOOL)preferencesExist
{
  return [[NSFileManager defaultManager] 
          fileExistsAtPath:[DBFileUtils preferencesFilePath]];
}

// Checks to see if the preferences file exists in Dropbox
+ (BOOL)dropboxPreferencesExist
{
  return [[NSFileManager defaultManager] 
          fileExistsAtPath:[DBFileUtils dropboxPreferencesFilePath]];
}

// Checks to see if the preferences file exists on the local filesystem
+ (BOOL)localPreferencesExist
{
  return [[NSFileManager defaultManager]
          fileExistsAtPath:[DBFileUtils localPreferencesFilePath]];
}

// A convenience method to return the directory of the preferences file based
//  on the current syncing state
+ (NSString*)preferencesDirectoryPath
{
  if([DBStatus isDropboxSyncEnabled])
    return [DBFileUtils dropboxPreferencesDirectoryPath];
  else
    return [DBFileUtils localPreferencesDirectoryPath];
}

// A convenience method to return the file path of the preferences file based
//  on the current syncing state
+ (NSString*)preferencesFilePath
{
  if([DBStatus isDropboxSyncEnabled])
    return [DBFileUtils dropboxPreferencesFilePath];
  else
    return [DBFileUtils localPreferencesFilePath];
}

// Returns the path to the preferences file on Dropbox
+ (NSString*)dropboxPreferencesFilePath
{
  if(![DBUtils isDropboxAvailable])
    return nil;
  
  return [NSString stringWithFormat:@"%@/%@.plist",
          [self dropboxPreferencesDirectoryPath],[[NSBundle mainBundle] 
                                                  bundleIdentifier]];
}

// Returns the path to the preferences file on the local system
+ (NSString*)localPreferencesFilePath
{
  return [NSString stringWithFormat:@"%@%/%@.plist",
          [DBFileUtils localPreferencesDirectoryPath],
          [[NSBundle mainBundle] bundleIdentifier]];
}

// Returns a tilde expanded local path to the Preferences directory
+ (NSString*)localPreferencesDirectoryPath
{
  NSArray* directories = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
  NSString* appSupportDir = [NSString stringWithFormat:@"%@/%@/",
                             [directories objectAtIndex:0],
                             [[[NSBundle mainBundle] infoDictionary] 
                              objectForKey:@"CFBundleName"]];
  return appSupportDir;
}

// Returns the path to the Preferences directory on Dropbox
+ (NSString*)dropboxPreferencesDirectoryPath
{
  if(![DBUtils isDropboxAvailable])
    return nil;
  
  return [NSString stringWithFormat:@"%@/Preferences", [DBUtils dropboxPath]];
}

@end
