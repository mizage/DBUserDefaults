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


#import "DBUtils.h"
#import "DBNSString+Extensions.h"

@interface DBUtils ()
+ (NSString*)getHostFileContents;
@end

@implementation DBUtils

// Checks to see if Dropbox is installed and available
+ (BOOL)isDropboxAvailable
{
  return [self dropboxPath] != nil ? YES : NO;
}

// Attempts to read the second line of the Dropbox host file and decode it to
//  get the path to the Dropbox folder on the system
+ (NSString*)dropboxPath
{
  NSString* hostFileContents = [self getHostFileContents];
  
  if(!hostFileContents)
    return nil;
  
  NSArray* hostFileLines = 
  [hostFileContents componentsSeparatedByCharactersInSet:
   [NSCharacterSet newlineCharacterSet]];
  
  // Make sure we have a second line to read
  if([hostFileLines count] >= 2)
  {      
    // The location of the Dropbox folder is Base64 encoded on the second line
    //  of the host.db file
    NSString* base64DropboxPath = [hostFileLines objectAtIndex:1];    
    NSString* dropboxPath = [base64DropboxPath decodeBase64String];
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:dropboxPath])
      return nil;
    
    return dropboxPath;    
  }
  
  return nil; 
}

// Attempts to read the contents of the Dropbox host file located at
//  ~/.dropbox/host.db
+ (NSString*)getHostFileContents
{
  NSString* dropboxHostFile = 
  [@"~/.dropbox/host.db" stringByExpandingTildeInPath];
  
  if(![[NSFileManager defaultManager] fileExistsAtPath:dropboxHostFile])
    return nil;
  
  return [NSString stringWithContentsOfFile:dropboxHostFile 
                                   encoding:NSUTF8StringEncoding error:nil];
}

@end
