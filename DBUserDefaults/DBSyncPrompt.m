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
#import "NSImage+BundleLoading.h"

NSString* const DBSyncPromptUserDidCancelNotification = 
@"DBSyncPromptUserDidCancelNotification";

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
- (void)closeWindowWithCompletion:(void (^)(void))completionBlock;
- (void)finishClose:(void(^)(void))completionBlock;
@end


@implementation DBSyncPrompt

@synthesize delegate;

- (id)init
{    
  [NSBundle loadNibNamed:@"DBSyncPrompt" owner:self];
  [[self window] center];
  [[self window] setLevel:NSFloatingWindowLevel];
  [[self window] setContentBorderThickness:34 forEdge:NSMinYEdge];
  
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
  [localPrefIcon setHidden:NO];
  [dropboxPrefIcon setHidden:YES];
  
  [transmitter setWantsLayer:YES];
  [[transmitter layer] setAnchorPoint:CGPointMake(0.5, 0.5)];
  
  [self rotateArrowToDegrees:-180.0f];
  currentSelection = DBSyncPromptOptionLocal; 
  
  
  currentFrame = 1;
  frameDelay = 0;
  
  linkColor = [[NSColor colorWithDeviceRed:91.0/255.0
                                     green:152.0/255.0 
                                      blue:221.0/255.0 
                                     alpha:1.0] retain];
  normalColor = [[NSColor colorWithDeviceRed:164.0/255.0
                                       green:164.0/255.0 
                                        blue:164.0/255.0 
                                       alpha:1.0] retain];
  
  
  linkFont = [[NSFont fontWithName:@"HelveticaNeue-Bold" size:13.0] retain];
  normalFont = [[NSFont fontWithName:@"LucidiaGrande" size:13.0] retain];
  
  // Set up all the attributes for link appearance except font, because font
  //  appears to be ignored in this call.
  [detailText setLinkTextAttributes:
   [NSDictionary dictionaryWithObjectsAndKeys:
    [NSCursor pointingHandCursor], NSCursorAttributeName, 
    linkColor, NSForegroundColorAttributeName,
    [NSNumber numberWithInt:NSNoUnderlineStyle], NSUnderlineStyleAttributeName,
    nil]];
  
  // Create a dictionary to hold all the attributes for normal text
  NSDictionary* normalAttributeDictionary = 
  [NSDictionary 
   dictionaryWithObjectsAndKeys: normalColor, NSForegroundColorAttributeName,
   normalFont, NSFontAttributeName, 
   nil];
  
  // Create a dictionary to hold all the attributes for link text
  NSDictionary* linkAttributeDictionary = 
  [NSDictionary dictionaryWithObjectsAndKeys:
   [NSURL URLWithString:@"http://www.dropbox.com"], NSLinkAttributeName,
   linkFont,NSFontAttributeName,
   nil];
  
  // Create a paragraph sytle to center the text
  NSMutableParagraphStyle* paragraphStyle = [[[NSMutableParagraphStyle alloc] init] autorelease];
  [paragraphStyle setAlignment:NSCenterTextAlignment]; 
  
  // If Dropbox is not installed, show a message and disable controls
  if(![DBUtils isDropboxAvailable])
  {
    [localButton setActive:NO];
    [localButton setEnabled:NO];
    [dropboxButton setActive:NO];
    [dropboxButton setEnabled:NO];
    [localButton setAlphaValue:0.25];
    [dropboxButton setAlphaValue:0.25];
    [transmitter setAlphaValue:0.25];
    [syncButton setEnabled:NO];
    [localPrefIcon setHidden:YES];
    [dropboxPrefIcon setHidden:YES];
    
    noDropboxLabel = [[[NSMutableAttributedString alloc] 
                       initWithString:@"Dropbox was not detected on your Mac.\n"
                       "Please visit the "
                       attributes:normalAttributeDictionary] autorelease];
    
    [noDropboxLabel appendAttributedString:
     [[[NSAttributedString alloc] initWithString:@"Dropbox Website"
                                      attributes:linkAttributeDictionary] autorelease]];
    [noDropboxLabel appendAttributedString:
     [[[NSAttributedString alloc] initWithString:@" to install it.\n"
       "Don't worry, it's free!"
                                      attributes:normalAttributeDictionary] autorelease]];
    
    [noDropboxLabel addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0,[noDropboxLabel length])];
    
    [[detailText textStorage] setAttributedString:noDropboxLabel];
    
  }
  else
  {    
    animationTimer = [NSTimer timerWithTimeInterval:0.1 target:self selector:@selector(nextFrame) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:animationTimer forMode:NSRunLoopCommonModes];
    
    [localButton setActive:YES];  
    
    NSString* appName = [self getAppName];
    
    localLabel = [[[NSMutableAttributedString alloc] 
                   initWithString:@"Push the preferences on this Mac up to "
                   attributes:normalAttributeDictionary] autorelease];
    
    [localLabel appendAttributedString:
     [[[NSAttributedString alloc] initWithString:@"Dropbox"
                                      attributes:linkAttributeDictionary] autorelease]];
    
    [localLabel appendAttributedString:
     [[[NSAttributedString alloc] initWithString:
       [NSString stringWithFormat:@" so all your copies of %@ will use your current settings.",appName]
                                      attributes:normalAttributeDictionary] autorelease]];
    
    [localLabel addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0,[localLabel length])];
    
    dropboxLabel = [[[NSMutableAttributedString alloc] 
                     initWithString:@"Pull the preferences from "
                     attributes:normalAttributeDictionary] autorelease];
    
    [dropboxLabel appendAttributedString:
     [[[NSAttributedString alloc] initWithString:@"Dropbox"
                                      attributes:linkAttributeDictionary] autorelease]];
    
    [dropboxLabel appendAttributedString:
     [[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" and use them as the settings for %@ on this Mac.",appName]
                                      attributes:normalAttributeDictionary] autorelease]];
    
    [dropboxLabel addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0,[dropboxLabel length])];
    
    [[detailText textStorage] setAttributedString:localLabel];
  }
  [[self window] setAlphaValue:0.0];
  [self showWindow:nil]; 
  
  return self;
}

// Animate the window being shown
- (void)showWindow:(id)sender
{
	[super showWindow:sender];
  [[[self window] animator] setAlphaValue:1.0];
}

// Animated the window closing
- (void)closeWindowWithCompletion:(void (^)(void))completionBlock
{
  [[[self window] animator] setAlphaValue:0.0];  
  [self performSelector:@selector(finishClose:) 
             withObject:[[completionBlock copy] autorelease] 
             afterDelay:0.25
                inModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
}

- (void)finishClose:(void(^)(void))completionBlock
{
  [[self window] orderOut:self];
  completionBlock();  
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
  NSImage* image = [NSImage imageNamed:[NSString stringWithFormat:@"transmitting-%d",currentFrame]
                                ofType:@"png"
                              inBundle:@"com.mizage.DBUserDefaults"];
  
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


// Called when the local button is clicked. Rotate the arrow to point
//  at Dropbox, and set state to sync up to dropbox.
- (IBAction)localClicked:(NSButton*)sender
{
  [self rotateArrowToDegrees:-180.0f];
  [[detailText textStorage] setAttributedString:localLabel];
  [localButton setActive:YES];
  [localButton setEnabled:NO];
  [dropboxButton setActive:NO];
  [dropboxButton setEnabled:YES];
  [localPrefIcon setHidden:NO];
  [dropboxPrefIcon setHidden:YES];
  
  currentSelection = DBSyncPromptOptionLocal;  
}

// Called when the Dropbox button is clicked. Rotate the arrow to point
//  at local, and set state to sync down from Dropbox.
- (IBAction)dropboxClicked:(NSButton*)sender
{
  [self rotateArrowToDegrees:0.0f];
  [[detailText textStorage] setAttributedString:dropboxLabel]; 
  [localButton setActive:NO];
  [localButton setEnabled:YES];
  [dropboxButton setActive:YES];
  [dropboxButton setEnabled:NO];
  [localPrefIcon setHidden:YES];
  [dropboxPrefIcon setHidden:NO];
  
  currentSelection = DBSyncPromptOptionDropbox;
}


// Accepts the current settings, informing the delegate of these settings and
//  dismissing the window
- (IBAction)syncClicked:(id)sender
{
  [animationTimer invalidate];
  animationTimer = nil;
  [self closeWindowWithCompletion:^
   {
     [delegate syncPromptDidSelectOption:currentSelection];  
     [[NSApplication sharedApplication] stopModal];
   }];  
}

// Cancels the request, hiding the window and informing the delegate of the
//  cancellation
- (IBAction)cancelClicked:(id)sender
{
  [animationTimer invalidate];
  animationTimer = nil;
  
  [self closeWindowWithCompletion:^
   {
     if([delegate respondsToSelector:@selector(syncPromptDidCancel)])
     {  
       [delegate syncPromptDidCancel];
     }
     [[NSApplication sharedApplication] stopModal];   
   }];
}

// Rotates the arrow to a given degree
- (void)rotateArrowToDegrees:(CGFloat)degrees
{
  NSNumber* numDegrees = DegreesToNumber(degrees);
  [[transmitter layer] setValue:numDegrees forKeyPath:@"transform.rotation.z"];
}

@end
