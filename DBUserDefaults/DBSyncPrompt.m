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

#import "DBSyncPrompt.h"
#import <QuartzCore/QuartzCore.h>

static NSString* localLabel = @"Pull the preferences from Dropbox and use them for %@ on this Mac.";
static NSString* dropboxLabel = @"Push the preferences on this Mac up to Dropbox so all copies of %@ will use them.";

CGFloat DegreesToRadians(CGFloat degrees)
{
  return degrees * M_PI / 180;
};
NSNumber* DegreesToNumber(CGFloat degrees)
{
  return [NSNumber numberWithFloat:
          DegreesToRadians(degrees)];
}

@interface DBSyncPrompt ()
- (void)rotateArrowToDegrees:(NSInteger)degrees;
@end

@implementation DBSyncPrompt

@synthesize delegate;

- (id)init
{
  NSWindow* window = [[[NSWindow alloc] 
                       initWithContentRect:NSMakeRect(0, 0, 411, 322)
                       styleMask:NSBorderlessWindowMask
                       backing:NSBackingStoreBuffered
                       defer:NO] autorelease];
  [window setHasShadow:YES];
  
  if((self = [super initWithWindow:window]))
  {
    [window center];
    [window setLevel:NSFloatingWindowLevel];
    
    [NSBundle loadNibNamed:@"DBSyncPrompt" owner:self];
    
    [arrow setWantsLayer:YES];
    [[arrow layer] setAnchorPoint:CGPointMake(0.5, 0.5)];
    
    [dropboxButton setState:NSOnState];
    [dropboxButton setEnabled:NO];

    NSString* appName = [[[NSBundle mainBundle] infoDictionary] 
                         objectForKey:@"CFBundleDisplayName"];
    [detailText setStringValue:[NSString stringWithFormat:dropboxLabel,
                                appName != nil ? appName : @""]];
    
    NSString* appIconName = [[NSBundle mainBundle] objectForInfoDictionaryKey:
                             @"CFBundleIconFile"];
    NSImage* icon;
    if(appIconName)
      icon = [NSImage imageNamed:appIconName];
    else
      icon = [[NSWorkspace sharedWorkspace] 
              iconForFileType:
              NSFileTypeForHFSTypeCode(kGenericApplicationIcon)];
    
    [localButton setImage:icon];
    


    
    [window setContentView:view];
  }
  
  return self;
}

- (void)dealloc
{
  [super dealloc];
}

- (void)displayPrompt
{
  [[NSApplication sharedApplication] runModalForWindow:[self window]];
}

- (IBAction)dropboxClicked:(NSButton*)sender
{
  [self rotateArrowToDegrees:0];
  [dropboxButton setEnabled:NO];
  [localButton setEnabled:YES];  
  NSString* appName = [[[NSBundle mainBundle] infoDictionary] 
                       objectForKey:@"CFBundleDisplayName"];
  [detailText setStringValue:[NSString stringWithFormat:dropboxLabel,
                              appName != nil ? appName : @""]];
  
  currentSelection = DBSyncPromptOptionDropbox;
}

- (IBAction)localClicked:(NSButton*)sender
{
  [self rotateArrowToDegrees:-180];
  [dropboxButton setEnabled:YES];
  [localButton setEnabled:NO];
  NSString* appName = [[[NSBundle mainBundle] infoDictionary] 
                       objectForKey:@"CFBundleDisplayName"];
  [detailText setStringValue:[NSString stringWithFormat:localLabel,
                              appName != nil ? appName : @""]];
  
  currentSelection = DBSyncPromptOptionLocal;  
}

- (IBAction)acceptclicked:(id)sender
{
  [[self window] orderOut:nil];
  [delegate syncPromptDidSelectOption:currentSelection];  
  [[NSApplication sharedApplication] stopModal];
}

- (IBAction)cancelClicked:(id)sender
{
  [[self window] orderOut:nil];
  [delegate syncPromptDidCancel];
  [[NSApplication sharedApplication] stopModal];
}

- (void)rotateArrowToDegrees:(NSInteger)degrees
{
  NSNumber* numDegrees = DegreesToNumber(degrees);
  CABasicAnimation* rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
  rotationAnimation.toValue = numDegrees;
  rotationAnimation.duration = 0.25;
  [[arrow layer] addAnimation:rotationAnimation forKey:@"rotationAnimation"];
  [[arrow layer] setValue:numDegrees forKeyPath:@"transform.rotation.z"];
}

@end
