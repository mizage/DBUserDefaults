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

#import <QuartzCore/QuartzCore.h>

#import "DBSyncPrompt.h"
#import "DBSyncButton.h"
#import "DBUtils.h"
#import "NSAttributedString+Hyperlink.h"

static inline CGFloat DegreesToRadians(CGFloat degrees)
{
  return degrees * M_PI / 180;
};
static inline NSNumber* DegreesToNumber(CGFloat degrees)
{
  return [NSNumber numberWithFloat:
          DegreesToRadians(degrees)];
}


@interface DBSyncPrompt ()
- (NSString*)getAppName;
- (void)rotateArrowToDegrees:(CGFloat)degrees;
@end


@implementation DBSyncPrompt

@synthesize delegate;

- (id)init
{    
  [NSBundle loadNibNamed:@"DBSyncPrompt" owner:self];
  [[self window] center];
  [[self window] setLevel:NSFloatingWindowLevel];
  [[self window] setContentBorderThickness:55 forEdge:NSMinYEdge];
  
  [self rotateArrowToDegrees:-180.0f];
  
  currentSelection = DBSyncPromptOptionLocal; 
  
  NSString* appIconName = [[NSBundle mainBundle] objectForInfoDictionaryKey:
                           @"CFBundleIconFile"];
  
  // Attempt to get the icon of the application in which we are running
  // If this fails, get the generic application icon instead
  NSImage* icon;
  if(appIconName)
    icon = [NSImage imageNamed:appIconName];
  else
    icon = [[NSWorkspace sharedWorkspace] 
            iconForFileType:
            NSFileTypeForHFSTypeCode(kGenericApplicationIcon)];
  
  [localButton setImage:icon];
  
  [transmitter setWantsLayer:YES];
  [[transmitter layer] setAnchorPoint:CGPointMake(0.5, 0.5)];
  
  currentFrame = 1;
  frameDelay = 0;
  
  linkColor = [[NSColor colorWithDeviceRed:91.0/255.0
                                     green:152.0/255.0 
                                      blue:221.0/255.0 
                                     alpha:1.0] retain];
  linkFont = [[NSFont fontWithName:@"HelveticaNeue-Bold" size:13.0] retain];
  
  if(YES)//![DBUtils isDropboxAvailable])
  {
    [localButton setActive:NO];
    [localButton setEnabled:NO];
    [dropboxButton setActive:NO];
    [dropboxButton setEnabled:NO];
    [localButton setAlphaValue:0.25];
    [dropboxButton setAlphaValue:0.25];
    [transmitter setAlphaValue:0.25];
    [syncButton setEnabled:NO];
    
    
    /*
     static NSString* localLabel = @"Pull the preferences from Dropbox and use them"
     " for %@ on this Mac.";
     static NSString* dropboxLabel = @"Push the preferences on this Mac up to" 
     " Dropbox so all your copies of %@ will"
     " use them.";
     static NSString* noDropboxLabel = @"Dropbox was not detected on your Mac.\n"
     "Please visit the Dropbox Website to install it.\n"
     "Don't worry, it's free!";
     
     for color, default text: RGB: 164, 164, 164
     2:18 PM
     Adam B.	
     link color: RGB 91, 152, 221
     Helvetica Neue, 13pt for link
     */
    noDropboxLabel = [[[NSMutableAttributedString alloc] 
                       initWithString:@"Dropbox was not detected on your Mac.\n"
                       "Please visit the "] autorelease];
    [noDropboxLabel appendAttributedString:
     [NSAttributedString hyperlinkFromString:@"Dropbox Website"
                                     withURL:[NSURL URLWithString:@"http://www.dropbox.com"]
                                   withColor:linkColor 
                                    withFont:linkFont
                                  underlined:NO]];
    [noDropboxLabel appendAttributedString:
     [[NSAttributedString alloc] initWithString:@" to install it.\n"
      "Don't worry, it's free!"]];
    
    NSMutableParagraphStyle* paragraphStyle = [[[NSMutableParagraphStyle alloc] init] autorelease];
    [paragraphStyle setAlignment:NSCenterTextAlignment]; 
    
    [noDropboxLabel addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0,[noDropboxLabel length])];
    
    [detailText setAttributedStringValue:noDropboxLabel];
    [detailText setAllowsEditingTextAttributes:NO];
  }
  else
  {    
    animationTimer = [NSTimer timerWithTimeInterval:0.1 target:self selector:@selector(nextFrame) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:animationTimer forMode:NSRunLoopCommonModes];
    
    [localButton setActive:YES];  
    
    NSString* appName = [self getAppName];
    [detailText setStringValue:[NSString stringWithFormat:dropboxLabel,
                                appName != nil ? appName : @""]];
    
  }
  
  return self;
}

- (NSString*)getAppName
{
  NSString* appName = [[[NSBundle mainBundle] infoDictionary] 
                       objectForKey:@"CFBundleDisplayName"];
  if(!appName)
  {
    appName = [[[NSBundle mainBundle] infoDictionary] 
               objectForKey:@"CFBundleName"];
  }
  return appName; 
}

- (void)nextFrame
{
  NSBundle* frameworkBundle = [NSBundle bundleWithIdentifier:@"com.mizage.DBUserDefaults"];
  NSString* imageName = [NSString stringWithFormat:@"transmitting-%d",currentFrame];
  NSString* imagePath = [frameworkBundle pathForResource:imageName ofType:@"png"];
  
  NSImage *image = [[NSImage alloc] initWithContentsOfFile:imagePath];
  
  [transmitter setImage:image];
  
  
  if(currentFrame == 6 && frameDelay == 5)
  {
    currentFrame = 1;
    frameDelay = 0;
  }
  else if(currentFrame == 6)
  {
    frameDelay++;
  }
  else
  {
    currentFrame++;
  }  
}


// Brings up the SyncPrompt window in modal mode.
- (void)displayPrompt
{
  [[NSApplication sharedApplication] runModalForWindow:[self window]];
}


// Called when the Dropbox button is clicked. Rotates the arrow to point
//  from Dropbox to local, and sets state accordingly
- (IBAction)localClicked:(NSButton*)sender
{
  [self rotateArrowToDegrees:-180.0f];
  NSString* appName = [self getAppName];
  [detailText setStringValue:[NSString stringWithFormat:dropboxLabel,
                              appName != nil ? appName : @""]];
  
  [localButton setActive:YES];
  [localButton setEnabled:NO];
  [dropboxButton setActive:NO];
  [dropboxButton setEnabled:YES];
  
  currentSelection = DBSyncPromptOptionLocal;  
}

// Called when the Dropbox button is clicked. Rotates the arrow to point
//  from local to Dropbox, and sets state accordingly
- (IBAction)dropboxClicked:(NSButton*)sender
{
  [self rotateArrowToDegrees:0.0f];
  NSString* appName = [self getAppName];
  [detailText setStringValue:[NSString stringWithFormat:localLabel,
                              appName != nil ? appName : @""]];
  
  [localButton setActive:NO];
  [localButton setEnabled:YES];
  [dropboxButton setActive:YES];
  [dropboxButton setEnabled:NO];
  
  currentSelection = DBSyncPromptOptionDropbox;
}


// Accepts the current settings, informing the delegate of these settings and
//  dismissing the window
- (IBAction)syncClicked:(id)sender
{
  [animationTimer invalidate];
  animationTimer = nil;
  [[self window] orderOut:nil];
  [delegate syncPromptDidSelectOption:currentSelection];  
  [[NSApplication sharedApplication] stopModal];
}

// Cancels the request, hiding the window and informing the delegate of the
//  cancellation
- (IBAction)cancelClicked:(id)sender
{
  [animationTimer invalidate];
  animationTimer = nil;
  
  [[self window] orderOut:nil];
  
  if([delegate respondsToSelector:@selector(syncPromptDidCancel)])
  {  
    [delegate syncPromptDidCancel];
  }
  [[NSApplication sharedApplication] stopModal];
}

// Rotates the arrow to a given degree
- (void)rotateArrowToDegrees:(CGFloat)degrees
{
  NSNumber* numDegrees = DegreesToNumber(degrees);
  [CATransaction begin];
  [CATransaction setValue:(id)kCFBooleanTrue
                   forKey:kCATransactionDisableActions];
  [[transmitter layer] setValue:numDegrees forKeyPath:@"transform.rotation.z"];
  [CATransaction commit];  
}

@end
