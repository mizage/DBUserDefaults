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

#import "DBSyncButton.h"


@implementation DBSyncButton

- (void)awakeFromNib
{
  [(DBSyncButtonCell*)[self cell] setDelegate:self]; 
  [(DBSyncButtonCell*)[self cell] setImageDimsWhenDisabled:NO];
  
  enabled_ = YES;
}

// Override setEnabled so we can keep our own flag for custom drawing
- (void)setEnabled:(BOOL)flag
{
  [super setEnabled:flag];
  enabled_ = flag;
}

// Delegate method from our cell. Informs us when to enable highlighting
- (void)DBSyncButtonCellDidBeginHighlight
{
  if(!enabled_)
    return;

  highlighted_ = YES;
  [self setNeedsDisplay];
}

// Delegate method from our cell. Informs us when to disable highlighting
- (void)DBSyncButtonCellDidEndHighlight
{
  if(!enabled_)
    return;
  
  highlighted_ = NO;
  [self setNeedsDisplay];
}

// Override drawRect to get our own custom background and image on top
- (void)drawRect:(NSRect)dirtyRect
{  
  NSBundle* frameworkBundle = [NSBundle bundleWithIdentifier:@"com.mizage.DBUserDefaults"];
  NSString* imageName;
  
  // The button is active, set the active state
  if(active_)
  {
    imageName = @"iconbox-active";
  }
  // The button is inactive, set the inactive state
  else
  {
    // The button is being pressed
    if(highlighted_)
    {
      imageName = @"iconbox-inactive-click";
    }
    // The button is not being pressed
    else
    {
      imageName = @"iconbox-inactive";  
    }
  }
  
  NSString* imagePath = [frameworkBundle pathForResource:imageName ofType:@"png"];  
  NSImage *image = [[NSImage alloc] initWithContentsOfFile:imagePath];  
  [image drawAtPoint:NSMakePoint(0, 0) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];  
  [image release];
  
  [[self cell] drawWithFrame:CGRectInset([self bounds], 15, 15) inView:self];
  
}

// Used to set the active state of our button. Draws a different image.
- (void)setActive:(BOOL)active
{
  active_ = active;
  [self setNeedsDisplay];
}

@end
